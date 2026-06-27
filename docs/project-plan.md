# Project Plan

## Goal

The goal is not to build a complete Dealer Management System (DMS). The goal is to build a small but complete DMS slice that proves the application can run, be deployed, and evolve safely through AI-assisted workflows.

The core differentiator is the agentic architecture: a customer-facing assistant creates structured workshop tickets, sales leads, and proposed actions, while an authenticated admin interface lets dealership staff review and approve those actions.

The project should demonstrate:

- a working DMS baseline;
- a customer-facing AI experience;
- vehicle inventory and AI-assisted recommendations;
- multi-agent orchestration across service and sales workflows;
- retrieval-augmented generation through a vector knowledge base;
- human-in-the-loop approval;
- tests, evaluations, and observability around AI behavior;
- clear rails for implementing future unknown features during the interview.

## Product Shape

There are two separate product surfaces.

### 1. Customer Website

The customer website exposes two customer-facing experiences.

#### Customer Chat Route

Route: `/customer/chat`

This is the customer-facing AI entry point. A customer can describe a workshop need, a vehicle purchase intent, or both in natural language.

Example requests:

- "My car makes a grinding noise when I brake."
- "I need to book the annual service before Friday."
- "I am looking for a family SUV under 30k."
- "I need a service appointment, and I am also interested in hybrid cars."

The chat should not directly mutate critical DMS data. It should collect information, run the multi-agent workflow, and create structured workshop tickets, sales leads, and proposed actions.

The customer chat is responsible for:

- collecting the customer identity;
- collecting vehicle ownership information when the request is service-related;
- collecting vehicle search preferences when the request is sales-related;
- understanding service, sales, or mixed intent;
- asking follow-up questions when required;
- producing a workshop ticket, a sales lead, or both;
- showing a simple confirmation that the request has been sent to the dealership team.

#### Vehicles for Sale Route

Route: `/customer/vehicles`

This route displays vehicles currently available for sale.

The vehicles for sale route is responsible for:

- listing available vehicles;
- showing a vehicle detail page;
- supporting simple filters such as budget, brand, energy type, transmission, mileage, and body style;
- providing a "recommend vehicles for me" entry point;
- allowing the customer to start a sales conversation from a vehicle or from their preferences.

### 2. Admin Dashboard

Route: `/admin`

This is the internal dealership surface. It requires authentication.

The admin dashboard is responsible for:

- listing incoming workshop tickets;
- listing incoming sales leads;
- showing ticket and lead details;
- showing agent-generated analysis;
- showing proposed actions;
- showing retrieved knowledge sources when relevant;
- allowing staff to approve, reject, or adjust actions;
- creating actual DMS records only after human approval.

This makes the AI feature safe and realistic: customers express intent, agents prepare work, humans validate.

## Functional Baseline

The DMS baseline should be intentionally small.

### Authentication

- Admin login.
- Admin logout.
- Seeded admin user for demo.

### Customers

- List customers.
- Create customer.
- View customer details.

### Customer-Owned Vehicles

- A vehicle belongs to a customer.
- Fields: VIN, brand, model, year, mileage when available.
- View vehicles linked to a customer.

### Vehicles for Sale

Vehicles for sale represent the dealership inventory visible to customers.

A vehicle for sale should contain:

- brand;
- model;
- year;
- price;
- mileage;
- energy type: petrol, diesel, hybrid, electric, other;
- transmission;
- body style;
- short description;
- availability status;
- optional image URL;
- optional links to knowledge base documents such as brochures, warranty notes, or maintenance information.

### Workshop Appointments

- Create appointment after staff approval.
- Fields: customer, vehicle, requested service, scheduled date/time, status.
- Suggested statuses: `requested`, `confirmed`, `in_progress`, `done`, `cancelled`.

### Workshop Tickets

Tickets are the bridge between the customer chat and the admin service workflow.

A workshop ticket should contain:

- customer message;
- normalized customer identity;
- vehicle information;
- triage summary;
- urgency;
- missing information;
- proposed actions;
- approval status;
- agent trace identifier.

### Sales Leads

Sales leads are the bridge between the customer chat, the vehicle inventory, and the admin sales workflow.

A sales lead should contain:

- customer message;
- normalized customer identity;
- extracted preferences;
- budget range;
- intended usage;
- recommended vehicles;
- recommendation rationale;
- retrieved knowledge sources;
- missing information;
- proposed actions;
- approval status;
- agent trace identifier.

### Proposed Actions

Actions are generated by agents but require admin confirmation.

Examples:

- create customer;
- create customer-owned vehicle;
- create workshop appointment;
- ask customer for missing mileage;
- flag service request as urgent;
- create sales lead;
- recommend vehicles;
- propose a test drive;
- ask customer for missing budget or usage information;
- assign manual review.

## Knowledge Base and Vector Search

The project should include a small vectorized knowledge base to demonstrate retrieval-augmented generation.

The knowledge base should contain seeded dealership documents such as:

- vehicle brochures;
- warranty notes;
- maintenance plans;
- EV and hybrid FAQ;
- financing FAQ;
- trade-in FAQ;
- sales argument notes.

The vector database should support semantic search through a dedicated `Knowledge Agent` tool.

Example tool:

```ts
searchKnowledgeBase({
  query: string,
  filters?: {
    sourceType?: "brochure" | "warranty" | "maintenance" | "faq" | "financing";
    vehicleModel?: string;
  };
})
```

The retrieved chunks should be visible in traces and, when relevant, in the admin lead or ticket detail page.

The vector DB is used to answer questions such as:

- what warranty applies to a battery;
- whether a hybrid vehicle fits long-distance usage;
- what maintenance is expected for a model;
- what arguments support a recommendation;
- what financing or trade-in information should be mentioned.

## Multi-Agent Workflow

The customer-facing chat calls a backend orchestrator. The orchestrator delegates to specialized agents depending on the detected intent.

```txt
Customer Chat
   |
   v
Conversation Orchestrator / Intent Router
   |
   +-- Service Workflow
   |     +-- Customer Identification Agent
   |     +-- Vehicle Identification Agent
   |     +-- Workshop Triage Agent
   |     +-- Scheduling Agent
   |     +-- Knowledge Agent
   |     +-- Communication Agent
   |
   +-- Sales Workflow
   |     +-- Preference Agent
   |     +-- Inventory Agent
   |     +-- Knowledge Agent
   |     +-- Recommendation Agent
   |     +-- Communication Agent
   |
   +-- Safety / Approval Agent
   |
   v
Workshop Ticket and/or Sales Lead + Proposed Actions
   |
   v
Admin Dashboard
   |
   v
Human Approval
   |
   v
DMS Mutation
```

### Conversation Orchestrator / Intent Router

Responsibilities:

- understand whether the request is service-related, sales-related, or mixed;
- maintain conversation state;
- decide which agents are required;
- run service and sales workflows independently when both are needed;
- merge agent outputs into one customer-facing response;
- prevent direct critical mutations;
- create a traceable execution record.

### Customer Identification Agent

Responsibilities:

- detect whether the customer already exists;
- normalize name, email, and phone;
- identify missing information;
- propose customer creation when needed.

### Vehicle Identification Agent

Responsibilities:

- detect customer-owned vehicle details from the conversation;
- match a vehicle to an existing customer when possible;
- identify missing VIN, brand, model, year, or mileage;
- propose vehicle creation when needed.

### Workshop Triage Agent

Responsibilities:

- classify the request: maintenance, diagnostic, repair, warranty, recall, other;
- estimate urgency;
- estimate appointment duration;
- summarize symptoms and constraints;
- identify safety-sensitive cases requiring manual review;
- call the Knowledge Agent when warranty, maintenance, or model-specific context is needed.

### Scheduling Agent

Responsibilities:

- inspect existing appointments;
- suggest available slots;
- avoid proposing past dates;
- avoid double-booking;
- return alternatives when the preferred slot is unavailable.

### Preference Agent

Responsibilities:

- extract explicit vehicle purchase preferences;
- infer soft preferences from natural language, such as "family car" or "low running cost";
- identify missing preference data;
- produce a structured preference profile.

### Inventory Agent

Responsibilities:

- query available vehicles for sale;
- filter by hard constraints such as budget, energy type, mileage, body style, and transmission;
- return candidate vehicles for recommendation.

### Knowledge Agent

Responsibilities:

- query the vector knowledge base;
- retrieve relevant chunks from brochures, warranty notes, maintenance plans, and FAQs;
- return source-aware evidence to other agents;
- avoid answering from unsupported knowledge when retrieval is insufficient.

### Recommendation Agent

Responsibilities:

- rank inventory candidates against customer preferences;
- combine structured inventory data with retrieved knowledge;
- explain trade-offs;
- recommend a small set of vehicles;
- create a rationale suitable for both the customer and the admin sales lead.

### Communication Agent

Responsibilities:

- generate customer-facing replies;
- ask concise follow-up questions;
- summarize the current status of the request;
- explain recommendations clearly;
- keep tone professional and dealership-appropriate.

### Safety / Approval Agent

Responsibilities:

- decide whether proposed actions are safe to show;
- ensure critical actions require human approval;
- flag ambiguous, urgent, or risky requests;
- validate that generated actions respect domain rules;
- ensure recommendations do not make unsupported claims beyond retrieved sources and inventory data.

## Human-in-the-Loop Rule

Agents may propose actions but must not directly perform irreversible or business-critical operations.

Allowed automatically:

- create a draft workshop ticket;
- create a draft sales lead;
- classify a request;
- propose appointment slots;
- recommend vehicles;
- retrieve knowledge base sources;
- ask for missing information;
- draft a reply.

Requires admin approval:

- create or update a customer;
- create or update a customer-owned vehicle;
- create an appointment;
- cancel an appointment;
- mark a request as resolved;
- reserve a vehicle;
- schedule a test drive;
- send final dealership confirmation.

## Technical Architecture

Recommended stack:

- Next.js App Router;
- TypeScript;
- Prisma;
- PostgreSQL for deployed environment;
- SQLite or local PostgreSQL for local development;
- pgvector, Supabase Vector, Neon Postgres with vector support, or an equivalent vector store;
- Tailwind CSS;
- Vitest for unit tests;
- Playwright for end-to-end tests;
- AI SDK or equivalent abstraction for model calls;
- LangSmith or OpenTelemetry-compatible tracing for observability.

Suggested folders:

```txt
app/
  customer/chat/
  customer/vehicles/
  admin/
  admin/tickets/
  admin/leads/
  admin/customers/
  admin/vehicles/
  admin/appointments/

src/
  domain/
    customers/
    customer-vehicles/
    inventory/
    appointments/
    tickets/
    leads/
    proposed-actions/
    knowledge/

  application/
    tickets/
    leads/
    recommendations/
    appointments/
    approvals/
    knowledge-ingestion/

  infrastructure/
    db/
    auth/
    ai/
    vector-store/
    telemetry/

  agents/
    orchestrator/
    customer-identification/
    vehicle-identification/
    workshop-triage/
    scheduling/
    preference/
    inventory/
    knowledge/
    recommendation/
    communication/
    safety-approval/

  ai/
    prompts/
    schemas/
    evals/
    tools/
    traces/

tests/
  unit/
  e2e/

evals/
  datasets/
  runners/

knowledge/
  brochures/
  warranty/
  maintenance/
  faq/
  financing/
```

## AI Testing and Evaluation

The project should not only call an LLM. It should prove that the AI system is testable.

### Unit Tests

- domain rules;
- ticket creation;
- lead creation;
- proposed action validation;
- scheduling constraints;
- recommendation constraints;
- vector search filtering;
- schema validation of agent outputs.

### E2E Tests

- customer sends a service chat request;
- system creates a workshop ticket;
- customer sends a sales chat request;
- system creates a sales lead with recommendations;
- customer sends a mixed service and sales request;
- system creates both a workshop ticket and a sales lead;
- admin sees generated tickets and leads;
- admin approves a proposed appointment;
- admin approves a proposed test drive or follow-up;
- DMS records are created only after approval.

### AI Evals

Create a small dataset of representative customer messages.

Examples:

- simple annual service request;
- urgent brake issue;
- missing vehicle information;
- preferred slot unavailable;
- family SUV recommendation request;
- hybrid versus electric question;
- warranty question requiring vector retrieval;
- mixed service and sales request;
- ambiguous message;
- request requiring manual review.

Evaluate:

- intent routing;
- missing information detection;
- urgency classification;
- sales preference extraction;
- inventory filtering;
- retrieval relevance;
- source-grounded recommendation quality;
- safe proposed actions;
- no direct mutation without approval;
- response quality.

### Observability

Each customer chat workflow should produce a trace containing:

- conversation id;
- ticket id when created;
- lead id when created;
- selected agents;
- tool calls;
- vector search queries;
- retrieved chunks and source metadata;
- model inputs/outputs where safe;
- structured outputs;
- evaluation metadata;
- final proposed actions.

## Demo Narrative

1. Open `/customer/vehicles` and show available dealership inventory.
2. Open `/customer/chat`.
3. Send a realistic service request and show that a workshop ticket is created.
4. Send a realistic sales request and show vehicle recommendations based on inventory and retrieved knowledge.
5. Send a mixed request and show that the orchestrator splits it into service and sales workflows.
6. Open `/admin`.
7. Review generated workshop tickets, sales leads, agent analysis, retrieved sources, and proposed actions.
8. Approve an action.
9. Show that the DMS record is created only after approval.
10. Show traces, vector retrieval, tests, and evals.
11. Explain how the same rails support unknown feature implementation during the interview.

## What Not to Build Initially

Do not start with:

- invoicing;
- payments;
- full financing workflow;
- parts inventory;
- warranty claim processing;
- OEM integrations;
- advanced role-based access control;
- real email/SMS sending;
- complex technician planning;
- full dealership ERP behavior.

Allowed in the baseline:

- simple vehicle inventory;
- simple vehicle recommendations;
- sales lead creation;
- vectorized knowledge base;
- retrieval-grounded answers;
- admin approval flow.

## Strategic Positioning

This project should be presented as an AI-first dealership assistant:

- the DMS baseline proves product grounding;
- the customer chat proves a realistic AI entry point;
- the vehicle inventory proves sales-domain coverage;
- the ticket/action model proves operational safety;
- the sales lead model proves commercial value;
- the admin approval flow proves human-in-the-loop design;
- the multi-agent backend proves Staff AI engineering capability;
- the vector knowledge base proves retrieval and grounding capability;
- the eval and observability layers prove production maturity.
