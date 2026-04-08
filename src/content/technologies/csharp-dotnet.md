---
title: "GitHub Copilot for C#/.NET"
description: "Master Copilot's C# and .NET capabilities — from ASP.NET Core APIs and Entity Framework to xUnit testing and modern C# patterns."
language: "C#/.NET"
icon: "🟣"
difficulty: intermediate
duration: "45 minutes"
tags: ["csharp", "dotnet", "aspnet", "entity-framework", "xunit"]
lastUpdated: 2026-04-08
order: 4
---

# GitHub Copilot for C#/.NET

C# and .NET provide a rich, strongly-typed foundation that GitHub Copilot leverages to generate remarkably accurate code. From ASP.NET Core minimal APIs and Entity Framework Core models to xUnit tests and modern C# features like records and pattern matching, Copilot understands the .NET ecosystem deeply. If you're building enterprise applications, microservices, or cloud-native apps, Copilot can accelerate every layer.

---

## Why Copilot Excels at C#/.NET

| Factor | Why It Matters |
|---|---|
| **Strong type system** | C#'s rich types, generics, and nullable reference types give Copilot precise context |
| **Convention-driven framework** | ASP.NET Core, EF Core, and .NET patterns are highly predictable |
| **XML documentation** | `///` comments provide structured metadata Copilot uses as prompts |
| **NuGet ecosystem** | Deep knowledge of popular packages (MediatR, FluentValidation, AutoMapper) |
| **Modern language features** | Records, pattern matching, and top-level statements align well with AI generation |

> **💡 Tip:** Enable nullable reference types in your project. The additional type information dramatically improves Copilot's suggestions.

---

## ASP.NET Core Minimal APIs

Copilot generates clean, modern minimal API endpoints with proper validation and response types.

### Example: CRUD Endpoints

**Prompt:**

```csharp
using Microsoft.AspNetCore.Http.HttpResults;

// Minimal API endpoints for managing products
// Uses FluentValidation for input validation
// Returns TypedResults for proper OpenAPI documentation

public static class ProductEndpoints
{
    public static void MapProductEndpoints(this WebApplication app)
    {
        var group = app.MapGroup("/api/products").WithTags("Products");
```

**Copilot generates:**

```csharp
        group.MapGet("/", async (AppDbContext db, int page = 1, int pageSize = 20) =>
        {
            var products = await db.Products
                .OrderByDescending(p => p.CreatedAt)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();

            return TypedResults.Ok(products);
        });

        group.MapGet("/{id:int}", async Task<Results<Ok<Product>, NotFound>> 
            (int id, AppDbContext db) =>
        {
            var product = await db.Products.FindAsync(id);
            return product is not null
                ? TypedResults.Ok(product)
                : TypedResults.NotFound();
        });

        group.MapPost("/", async Task<Results<Created<Product>, ValidationProblem>> 
            (CreateProductRequest request, IValidator<CreateProductRequest> validator, AppDbContext db) =>
        {
            var result = await validator.ValidateAsync(request);
            if (!result.IsValid)
                return TypedResults.ValidationProblem(result.ToDictionary());

            var product = new Product
            {
                Name = request.Name,
                Description = request.Description,
                Price = request.Price,
                CreatedAt = DateTime.UtcNow
            };

            db.Products.Add(product);
            await db.SaveChangesAsync();

            return TypedResults.Created($"/api/products/{product.Id}", product);
        });

        group.MapDelete("/{id:int}", async Task<Results<NoContent, NotFound>> 
            (int id, AppDbContext db) =>
        {
            var product = await db.Products.FindAsync(id);
            if (product is null) return TypedResults.NotFound();

            db.Products.Remove(product);
            await db.SaveChangesAsync();

            return TypedResults.NoContent();
        });
    }
}
```

### ✏️ Exercise

1. Create `OrderEndpoints.cs` with `public static class OrderEndpoints`
2. Write a comment: `// Minimal API endpoints for order management — create order, get order, list orders by customer`
3. Let Copilot generate the endpoints with `TypedResults` and see how it handles the order/customer relationship
4. Add: `// Endpoint to calculate order total with tax and discount` and review the generated logic

---

## Entity Framework Core Models

Copilot generates EF Core entities with relationships, configurations, and migrations support.

### Example: Fluent API Configuration

**Prompt:**

```csharp
// EF Core entity configuration for Product
// Includes index on Name, precision on Price, and soft delete query filter

public class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<Product> builder)
    {
```

**Copilot generates:**

```csharp
        builder.ToTable("Products");

        builder.HasKey(p => p.Id);

        builder.Property(p => p.Name)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(p => p.Description)
            .HasMaxLength(2000);

        builder.Property(p => p.Price)
            .HasPrecision(18, 2)
            .IsRequired();

        builder.Property(p => p.CreatedAt)
            .IsRequired()
            .HasDefaultValueSql("GETUTCDATE()");

        builder.Property(p => p.IsDeleted)
            .IsRequired()
            .HasDefaultValue(false);

        builder.HasIndex(p => p.Name);
        builder.HasIndex(p => p.CreatedAt);

        // Global query filter for soft delete
        builder.HasQueryFilter(p => !p.IsDeleted);

        // Relationships
        builder.HasOne(p => p.Category)
            .WithMany(c => c.Products)
            .HasForeignKey(p => p.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
```

### ✏️ Exercise

1. Write a `Product` class with properties for Id, Name, Description, Price, CategoryId, CreatedAt, and IsDeleted
2. Let Copilot generate a matching `ProductConfiguration` with fluent API
3. Add a comment: `// Navigation property to order items` and let Copilot add the relationship

---

## xUnit Testing with FluentAssertions

Copilot generates idiomatic xUnit tests with fixtures, theories, and FluentAssertions.

### Example: API Integration Tests

**Prompt:**

```csharp
public class ProductEndpointsTests : IClassFixture<WebApplicationFactory<Program>>
{
    private readonly HttpClient _client;

    public ProductEndpointsTests(WebApplicationFactory<Program> factory)
    {
        _client = factory.CreateClient();
    }

    // Test: GET /api/products returns 200 with list of products
```

**Copilot generates:**

```csharp
    [Fact]
    public async Task GetProducts_ReturnsOkWithProductList()
    {
        var response = await _client.GetAsync("/api/products");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var products = await response.Content.ReadFromJsonAsync<List<Product>>();
        products.Should().NotBeNull();
    }

    [Fact]
    public async Task GetProduct_ExistingId_ReturnsOkWithProduct()
    {
        var response = await _client.GetAsync("/api/products/1");

        response.StatusCode.Should().Be(HttpStatusCode.OK);
        var product = await response.Content.ReadFromJsonAsync<Product>();
        product.Should().NotBeNull();
        product!.Id.Should().Be(1);
    }

    [Fact]
    public async Task GetProduct_NonExistingId_ReturnsNotFound()
    {
        var response = await _client.GetAsync("/api/products/99999");

        response.StatusCode.Should().Be(HttpStatusCode.NotFound);
    }

    [Fact]
    public async Task CreateProduct_ValidRequest_ReturnsCreated()
    {
        var request = new CreateProductRequest("Test Product", "Description", 29.99m);

        var response = await _client.PostAsJsonAsync("/api/products", request);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
        response.Headers.Location.Should().NotBeNull();
        var product = await response.Content.ReadFromJsonAsync<Product>();
        product!.Name.Should().Be("Test Product");
    }

    [Theory]
    [InlineData("", "Description", 10.00)]
    [InlineData("Name", "", -1.00)]
    public async Task CreateProduct_InvalidRequest_ReturnsBadRequest(
        string name, string description, decimal price)
    {
        var request = new CreateProductRequest(name, description, price);

        var response = await _client.PostAsJsonAsync("/api/products", request);

        response.StatusCode.Should().Be(HttpStatusCode.BadRequest);
    }
```

### ✏️ Exercise

1. Create a unit test class for a `ProductService` with a mocked `AppDbContext`
2. Write: `// Test that CreateProduct throws when product name already exists`
3. Let Copilot generate the test with Moq setup and FluentAssertions
4. Continue with: `// Theory: test price validation with various edge cases` for parametrized tests

---

## Modern C# Patterns

Copilot leverages modern C# features — records, pattern matching, and primary constructors.

### Example: CQRS with MediatR

**Prompt:**

```csharp
// MediatR query to get products with pagination and optional category filter
// Returns a PagedResult<ProductDto>

public record GetProductsQuery(
    int Page = 1,
    int PageSize = 20,
    int? CategoryId = null
) : IRequest<PagedResult<ProductDto>>;

public class GetProductsQueryHandler : IRequestHandler<GetProductsQuery, PagedResult<ProductDto>>
{
```

**Copilot generates:**

```csharp
    private readonly AppDbContext _db;

    public GetProductsQueryHandler(AppDbContext db) => _db = db;

    public async Task<PagedResult<ProductDto>> Handle(
        GetProductsQuery request, CancellationToken cancellationToken)
    {
        var query = _db.Products.AsQueryable();

        if (request.CategoryId.HasValue)
            query = query.Where(p => p.CategoryId == request.CategoryId.Value);

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .OrderByDescending(p => p.CreatedAt)
            .Skip((request.Page - 1) * request.PageSize)
            .Take(request.PageSize)
            .Select(p => new ProductDto(p.Id, p.Name, p.Price, p.Category.Name))
            .ToListAsync(cancellationToken);

        return new PagedResult<ProductDto>(items, totalCount, request.Page, request.PageSize);
    }
}
```

### ✏️ Exercise

1. Write: `// MediatR command to create a new product with validation`
2. Let Copilot generate the command record, handler, and FluentValidation validator
3. Add a comment: `// Pipeline behavior for logging all MediatR requests` and see the generated middleware

---

## Common Patterns

| Prompt / Context | What Copilot Generates |
|---|---|
| `app.MapGet("/api/...` | Minimal API endpoint with typed results |
| `IEntityTypeConfiguration<T>` | Full EF Core fluent configuration |
| `[Fact]` or `[Theory]` in test class | Complete xUnit test with assertions |
| `// Background service that` | `BackgroundService` with cancellation support |
| `// Middleware for` + description | ASP.NET Core middleware class |
| `IRequest<T>` record | MediatR handler with async implementation |
| `// Extension method for` | Static class with `this` parameter extensions |
| `// Options class for` + config section | Options pattern with validation |

---

## Summary & Next Steps

You've explored how Copilot accelerates C#/.NET development:

- **ASP.NET Core minimal APIs** — typed endpoints with validation
- **EF Core models** — entities, configurations, and relationships
- **xUnit tests** — integration and unit tests with FluentAssertions
- **Modern C# patterns** — records, MediatR, CQRS, and pipeline behaviors

### What to Try Next

1. **Build a full ASP.NET Core API** from scratch with Copilot at every layer
2. **Try Blazor components** — Copilot handles Razor syntax and component lifecycle well
3. **Explore gRPC services** — Copilot generates protobuf-compatible service implementations
4. **Use Copilot Chat** for upgrading from .NET 6/7 to .NET 8/9 patterns
