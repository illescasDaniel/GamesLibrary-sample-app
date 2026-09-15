# The Hexagonal Architecture Playbook: iOS & Swift Edition

*(With Python Backend Comparisons)*

This playbook defines a strict, production-ready implementation of Hexagonal Architecture (Ports and Adapters) for modern Swift/SwiftUI applications. It isolates pure business logic from UI, databases, and network dependencies, ensuring high testability and flexibility.

## 1. Core Principles

1. **The Dependency Rule:** Dependencies must point **inward** toward the Core. The Core knows nothing about the outside world (no `import SwiftUI`, `import SwiftData`, or `import Stripe`).
2. **Ports are Interfaces:** The Core defines what it needs using protocols.
* **Inbound Ports:** Contracts the Core implements, which the UI calls. (Allows mocking the Core when testing the UI).
* **Outbound Ports:** Contracts the Core defines, which the Infrastructure implements. (Allows mocking the Database/Network when testing the Core).


3. **Adapters are Translators:** Adapters convert outside data (JSON, Database Models) into Core Domain Entities, and vice versa.
4. **No UI in the Core:** Formatting, colors, and string localization are strictly UI adapter concerns.

---

## 2. The Universal Blueprint (File Tree)

```text
You are extremely close, but if we want this to be the *ultimate, 100% complete playbook copy*, we left out a few minor files from our previous iterations!

Since we agreed earlier to use **Approach 2 (Protocol + Struct) for the Domain Service**, we need to reflect that. We also dropped the `PrimaryBackend` network files and the `Configuration/Logging` siblings in the last drawing.

Here is the truly complete, nothing-left-behind file tree to seal the playbook:

```text
```text
MyApp/
├── App/
│   └── MyAppApp.swift                           # SwiftUI entry point; creates AppContainer and injects via .environment()
│
├── Core/                                        # INSIDE: Pure business rules; completely isolated from I/O and UI
│   ├── Domain/
│   │   ├── Entities/
│   │   │   ├── User.swift                       # Pure struct representing a user; holds core state, no DB annotations
│   │   │   └── Payment.swift                    # Pure struct representing a payment; holds raw amounts and status
│   │   ├── ValueObjects/
│   │   │   └── Money.swift                      # Immutable struct handling currency and amount safely (prevents float math)
│   │   └── Services/
│   │       ├── TaxCalculating.swift             # Protocol defining the contract for tax calculation rules
│   │       └── StandardTaxService.swift         # Stateless struct implementing TaxCalculating; pure math, no side effects
│   │
│   └── Application/
│       ├── Ports/
│       │   ├── Inbound/
│       │   │   ├── FetchUserProfileUseCasePort.swift # Protocol defining how the UI can request user data
│       │   │   └── ProcessPaymentUseCasePort.swift   # Protocol defining how the UI can initiate a payment
│       │   └── Outbound/
│       │       ├── UserRepositoryPort.swift          # Protocol dictating how the Core wants to fetch/save users externally
│       │       └── PaymentGatewayPort.swift          # Protocol dictating how the Core expects to process external charges
│       │
│       └── UseCases/
│           ├── FetchUserProfileUseCase.swift    # Class implementing Inbound port; orchestrates fetching via Outbound port
│           └── ProcessPaymentUseCase.swift      # Class orchestrating tax service and payment gateway logic
│
└── Infrastructure/                              # OUTSIDE: I/O, Third-party Frameworks, UI, and Configurations
	├── Adapters/
	│   ├── Inbound/
	│   │   └── UI/                              # The primary driving adapter layer (SwiftUI)
	│   │       ├── Resources/                   
	│   │       │   ├── Assets.xcassets          # Image catalog, colors, and app icons
	│   │       │   ├── Localizable.strings      # Text translations for the UI layer
	│   │       │   └── Fonts/                   # Custom font files (.ttf, .otf)
	│   │       ├── Formatters/                  
	│   │       │   ├── CurrencyFormatter.swift  # Converts Money ValueObject into localized UI strings (e.g., "€10,00")
	│   │       │   └── DateDisplayFormatter.swift # Converts raw Date into human-readable strings (e.g., "Oct 12")
	│   │       ├── UserProfile/
	│   │       │   ├── UserProfileView.swift    # SwiftUI view rendering the user's profile screen
	│   │       │   └── UserProfileViewModel.swift # @Observable class holding UI state; calls FetchUserProfileUseCasePort
	│   │       └── Payment/
	│   │           ├── PaymentView.swift        # SwiftUI view for the checkout screen
	│   │           └── PaymentViewModel.swift   # @Observable class handling UI actions; calls ProcessPaymentUseCasePort
	│   │
	│   └── Outbound/                            # The driven adapter layer (Databases & APIs)
	│       ├── Repositories/
	│       │   └── UserRepository.swift         # Implements UserRepositoryPort; coordinates SwiftData and API fallback
	│       │
	│       ├── Database/SwiftData/
	│       │   ├── UserSDModel.swift            # @Model class representing the exact SQLite schema
	│       │   └── UserSDMapper.swift           # Translates between UserSDModel (DB) and User (Domain Entity)
	│       │
	│       └── Network/
	│           ├── PrimaryBackend/              
	│           │   ├── PrimaryUserAPIClient.swift # Handles raw HTTP calls to your main server for user data
	│           │   ├── UserDTO.swift            # Codable struct mirroring the exact JSON response shape
	│           │   └── UserDTOMapper.swift      # Translates between UserDTO (JSON) and User (Domain Entity)
	│           │
	│           └── StripeService/
	│               ├── StripeAPIClient.swift    # Implements PaymentGatewayPort; interacts with Stripe's APIs
	│               ├── StripePaymentDTO.swift   # Codable struct representing Stripe's expected JSON format
	│               └── StripePaymentMapper.swift # Translates Stripe's response models into Domain payment models
	│
	├── DependencyInjection/
	│   └── AppContainer.swift                   # @Observable root composition class; instantiates and wires everything
	│
	├── Networking/                              
	│   ├── HTTPClient.swift                     # Reusable URLSession wrapper for network requests; used by API clients
	│   └── APIEndpoint.swift                    # URL builder and route definitions for backend requests
	│
	├── Persistence/                             
	│   ├── SwiftDataContainer.swift             # Initializes the ModelContainer and configures disk storage paths
	│   └── Migrations/                          # Logic for upgrading the database schema between versions
	│
	├── Configuration/                           
	│   └── Environment.swift                    # Reads build settings (Dev/Prod URLs, API Keys) from .xcconfig files
	│
	└── Logging/                                 
		└── AppLogger.swift                      # Centralized OSLog wrapper used by adapters to log non-business events

```                   

```

This tree now perfectly matches every single concept, rule, and best practice we established. It has the pure domain math decoupled by a protocol, the UI completely separated with its own formatters and assets, and all adapters mapped properly to their Use Case ports!

```

---

## 3. Layer-by-Layer Breakdown & Python Comparisons

### Layer 1: Core / Domain

Contains Entities (identity-based), Value Objects (attribute-based), and Domain Services (pure logic).

* **Swift Implementation:** Domain Services are built as a `Struct` conforming to a `Protocol`. This allows you to inject a mock service into your Use Cases.
* **🐍 Python Contrast:** Python treats functions as first-class citizens. Instead of creating a class, pure domain services are simply **module-level free functions** (e.g., `def calculate_tax(amount: Decimal) -> Decimal:`). You inject them using the `Callable` type hint, or use `@patch` in `unittest.mock` during testing.

### Layer 2: Core / Application (Use Cases & Ports)

The Application layer defines the "Use Cases" (features). It coordinates fetching data via Outbound Ports, processing it via Domain logic, and returning it via Inbound Ports.

* **Inbound Ports (Use Cases):** Defined as `protocol`. The Use Case implements it. The UI ViewModel depends on it. This allows you to test the ViewModel by injecting a `MockUseCase`.
* **Outbound Ports (Repositories/Gateways):** Defined as `protocol`. The Use Case depends on it. The Infrastructure Adapter implements it. This allows you to test the Use Case by injecting a `MockRepository` (preventing actual DB/Network calls).
* **🐍 Python Contrast:** Modern Python uses the `typing.Protocol` class (structural subtyping) or `abc.ABC` (Abstract Base Classes) to define these Ports. A Use Case class takes these interface definitions in its `__init__`.

### Layer 3: Infrastructure (The Siblings)

Infrastructure holds the raw tools needed by the Adapters to do their jobs.

* **Networking:** Wraps `URLSession` (Swift) or `httpx` / `requests` (Python).
* **Persistence:** Sets up `ModelContainer` (SwiftData) or `SQLAlchemy` (Python).
* **Dependency Injection:** The Composition Root wiring it all together.

### Layer 4: Adapters (The Translators)

Adapters sit at the boundary. They implement the Core's Ports and translate data.

**Inbound Adapters (Driving):**
The UI triggers the Use Cases.

* **Resources:** `Assets.xcassets`, fonts, and `.strings` files live **here**, not in the Core or generic Infrastructure.
* **Formatters:** Converting a raw `Decimal` and `Date` to `"$1,000"` and `"Oct 12"` happens **here**, before hitting the view.
* **🐍 Python Contrast:** In a Python backend, the Inbound Adapter is usually a REST API controller (e.g., FastAPI routers). Instead of UI formatters, you have serializers (like Pydantic models) converting domain entities into HTTP JSON responses.

**Outbound Adapters (Driven):**
Databases and third-party APIs.

* **Mappers:** The code that translates a Domain Entity into an external schema lives **right next to the external schema**. A `UserSDMapper` belongs in the SwiftData folder, not in the Core.

---

## 4. Dependency Injection & Wiring

The App Container (Composition Root) instantiates the low-level infrastructure, wraps it in Outbound Adapters, passes those into Use Cases, and passes Use Cases into the Inbound Adapters (ViewModels/Views).

**SwiftUI Implementation (Modern iOS 17+):**
Uses the Observation framework. The container is an `@Observable` class instantiated at the app root and passed down via `.environment()`.

```swift
@Observable
final class AppContainer {
	// 1. Shared Infrastructure
	private var httpClient = StandardHTTPClient()
    
	// 2. Outbound Adapter injected with Infrastructure
	//    Returns the PORT (Protocol), hiding the concrete implementation
	private var userRepository: UserRepositoryPort {
		UserRepository(httpClient: httpClient)
	}
    
	// 3. Use Case injected with Outbound Adapter (Repository Port)
	//    Returns the PORT (Protocol)
	private var fetchUserProfileUseCase: FetchUserProfileUseCasePort {
		FetchUserProfileUseCase(repository: userRepository)
	}
    
	// 4. Factory for the Inbound Adapter (UI ViewModel)
	func makeUserProfileViewModel() -> UserProfileViewModel {
		UserProfileViewModel(useCase: fetchUserProfileUseCase)
	}
}

```

* **🐍 Python Contrast:** Python developers rarely build manual containers like this for large apps. They typically rely on frameworks like `dependency-injector` or FastAPI's native `Depends()` DI system, injecting at the route level.

---

## 5. Golden Rules & Cheat Sheet

| Element | Where does it belong? | Why? |
| --- | --- | --- |
| **Tax / Math Logic** | `Core/Domain/Services` | Pure business rules; no side effects. |
| **Repository Protocol** | `Core/Application/Ports/Outbound` | The Core must dictate how it gets data. |
| **Repository Class** | `Infrastructure/Adapters/Outbound` | Implementation requires DB/Network frameworks. |
| **Images & Fonts** | `Infrastructure/Adapters/Inbound/UI` | Purely presentation details. |
| **`DateFormatter`** | `Infrastructure/Adapters/Inbound/UI` | Formatting is a UI translation, not a domain rule. |
| **JSON DTO to Entity** | `Infrastructure/Adapters/Outbound` | The core shouldn't know the JSON structure of a 3rd-party API. |
| **`import SwiftUI`** | ONLY in `Infrastructure/Adapters/Inbound/UI` | UI frameworks must not bleed into the business logic. |
| **URLSession / httpx** | `Infrastructure/Networking` | Adapters should share one tuned HTTP client. |
