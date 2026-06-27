# Case study implementation options

Source brief summary:

- Build a deliberately small Dealer Management System slice.
- The app must run, deploy on a free-tier host, and include basic auth.
- The app is a pass/fail gate, not the main score.
- The main score is the AI engineering system around the app:
  - agent config and rules,
  - reusable skills and subagents,
  - day-2 agents,
  - eval and verification loop.
- In the live session, the panel will ask for a fresh unseen extension task. The repository should make that easy and safe.

## Option A: Service & Workshop Scheduling — recommended

### MVP scope

A small workshop scheduling module for a dealership.

Entities:

```ts
type Customer = {
  id: string;
  name: string;
  email: string;
  phone?: string;
};

type Vehicle = {
  id: string;
  customerId: string;
  vin: string;
  make: string;
  model: string;
  registrationNumber: string;
};

type WorkshopAppointmentStatus =
  | "requested"
  | "confirmed"
  | "in_progress"
  | "done"
  | "cancelled";

type WorkshopAppointment = {
  id: string;
  customerId: string;
  vehicleId: string;
  startsAt: string;
  endsAt: string;
  status: WorkshopAppointmentStatus;
  reason: string;
  notes?: string;
};
```

Screens:

- Login page protected by basic auth.
- Appointment dashboard.
- Appointment list.
- Appointment create/edit form.
- Appointment detail view.

AI-rails fit:

- Easy to scaffold new fields and statuses.
- Easy to test with deterministic fixtures.
- Easy to extend live.
- Good balance between product relevance and limited scope.

Prepared live extension examples:

- Add cancellation reason.
- Add technician assignment.
- Add workshop bay capacity.
- Add no-show status.
- Add customer search.
- Add next available slot calculation.

Verdict: **best choice**.

## Option B: Vehicle inventory

### MVP scope

Vehicle records, statuses, search, and basic stock dashboard.

Entities:

```ts
type VehicleStockStatus = "available" | "reserved" | "sold" | "in_preparation";

type VehicleStockItem = {
  id: string;
  vin: string;
  make: string;
  model: string;
  year: number;
  mileageKm: number;
  priceCents: number;
  status: VehicleStockStatus;
};
```

Strengths:

- Very simple to understand.
- Easy CRUD.
- Easy demo.

Weaknesses:

- Can look too generic.
- Live extensions may become UI-only unless deliberately designed.

Good live tasks:

- Add reserved-by customer.
- Add margin calculation.
- Add vehicle preparation checklist.
- Add duplicate VIN guard.

Verdict: safe, but less distinctive than workshop scheduling.

## Option C: Sales quote / deal

### MVP scope

Create a sales quote for a customer and vehicle, with line items and total.

Entities:

```ts
type SalesDealStatus = "draft" | "sent" | "accepted" | "lost";

type SalesDeal = {
  id: string;
  customerId: string;
  vehicleId: string;
  status: SalesDealStatus;
  discountCents: number;
  totalCents: number;
};
```

Strengths:

- Strong DMS relevance.
- Good business logic opportunities.

Weaknesses:

- Pricing can become complex quickly.
- Risk of over-scoping.

Good live tasks:

- Add trade-in value.
- Add financing monthly payment estimate.
- Add quote expiration.
- Add deal loss reason.

Verdict: strong, but higher complexity.

## Option D: Customer CRM

### MVP scope

Customer records, vehicles, interaction notes, and follow-up tasks.

Strengths:

- Easy to build.
- Lots of possible extensions.

Weaknesses:

- Less DMS-specific unless tied strongly to vehicles and dealership workflows.

Verdict: acceptable, but not the strongest signal.

## Final recommendation

Use **Service & Workshop Scheduling**.

It gives the best combination of:

- narrow MVP,
- real DMS relevance,
- visible workflow,
- meaningful schema and validation changes,
- credible live day-2 extension tasks,
- straightforward automated tests.

## Implementation sequence

1. Create the app shell with Next.js and TypeScript.
2. Add basic auth middleware.
3. Add Prisma schema and seed data.
4. Build appointment dashboard and CRUD.
5. Add tests for scheduling validation.
6. Add `AGENTS.md`, `CLAUDE.md`, `.cursorrules`.
7. Add reusable skill and day-2 agents.
8. Add CI gate.
9. Deploy.
10. Document the prepared day-2 task.

## What not to build

Avoid:

- full multi-module DMS,
- complex RBAC,
- OEM integrations,
- invoicing,
- real SMS/email delivery,
- advanced calendar drag-and-drop,
- LLM features inside the product unless they directly support the case study narrative.

The product should stay small so the rails are the star.
