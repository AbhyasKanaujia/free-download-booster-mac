# macOS Download Manager

## 1. Project Objective

This project is to build a **native macOS download manager** that is:

* Stable
* Simple to use
* Visually aligned with macOS standards
* Compliant with App Store policies

This is **not**:

* A port of any existing system
* A backend/library-first project
* A framework-building exercise

The goal is to **ship a usable product quickly**, and improve it iteratively.

---

## 2. Development Philosophy

We will follow this strict order:

1. Make it work
2. Make it usable
3. Improve quality
4. Optimize performance

We will NOT:

* Build a complete core system before UI
* Over-engineer for future scalability
* Delay user-visible features

---

## 3. Key Expectation (Non-Negotiable)

Every milestone must result in:

> A **working, testable UI feature** that can be verified end-to-end

If a milestone produces:

* Only classes
* Only internal logic
* Only tests

Then it is considered **incomplete**

---

## 4. Definition of Done

A task/milestone is complete only if:

* It is accessible via UI
* It works with real data (not mocked)
* It can be tested using clear steps
* It handles basic failure scenarios

---

## 5. Work Structure

### Goals (Monthly)

High-level capability
Example: “Support reliable multiple downloads”

### Milestones (Weekly)

Must produce visible functionality
Example: “User can download a file and see progress”

### Tasks (Daily)

Implementation steps
Example: “Add progress bar to UI”

---

## 6. Communication Expectations

### What You Will Receive (From Product Side)

Each instruction will include:

* Clear user outcome
* Scope boundaries (what NOT to build yet)
* Acceptance criteria (how it will be tested)

---

### What You Must Provide (On Completion)

Each milestone must include:

#### 1. Implementation Summary

Explain what was built in simple terms

#### 2. Test Instructions

Step-by-step:

* Open app
* Perform actions
* Expected outcome

#### 3. Known Limitations

Clearly mention:

* Missing features
* Temporary shortcuts
* Edge cases not handled yet

---

## 7. Critical Mistakes to Avoid

These have already slowed progress and must not continue:

### ❌ Building core systems without UI integration

Do not develop isolated libraries or engines without exposing them in UI

### ❌ Over-engineering early

Do not design for scalability or reuse before basic functionality exists

### ❌ Implementing ahead without alignment

Do not proceed to the next stage without confirmation or milestone closure

### ❌ Large, invisible work blocks

If work cannot be demonstrated in UI within a week, it is too large

---

## 8. Implementation Guidelines

* Prefer **simplest working solution**
* Avoid abstraction unless necessary for current feature
* Integrate with UI as early as possible
* Refactoring will happen later — not upfront

---

## 9. macOS Standards (Must Follow)

### UI & UX

* Use native components (SwiftUI/AppKit)
* Follow standard layout patterns (toolbar, sidebar, menus)
* Maintain clean and minimal interface

### System Integration

* Notifications via `UNUserNotificationCenter`
* File handling via Finder-compatible paths
* Support standard keyboard shortcuts
* Use `.part` files during download, rename on completion

### Performance & Concurrency

* No blocking on main thread
* UI updates on main thread only
* Safe concurrency handling

---

## 10. Testing Philosophy

* Focus on testing **implemented logic**, not Apple frameworks
* Cover:

  * Basic functionality
  * Failure cases (network issues, invalid URLs)
  * Edge conditions relevant to user experience

---

## 11. Incremental Feature Strategy

We will build features in thin vertical slices:

Example progression:

Week 1:

* Add URL → Start download → Show progress → Save file

Week 2:

* Pause / Resume

Week 3:

* Retry handling

Week 4:

* Multiple downloads (queue)

Each step must be:

* Complete
* Usable
* Testable

---

## 12. Constraints

* No BitTorrent or restricted functionality
* No background daemon architecture
* No unnecessary protocol implementations unless required

---

## 13. Decision Guidelines

Before implementing anything, ensure:

* It directly supports the current milestone
* It is visible or testable by the user
* It does not introduce unnecessary complexity

If unsure → clarify before proceeding

---

## 14. Collaboration Principle

This is a **product-first development process**:

* We prioritize **shipping working features**
* We iterate based on working software
* We avoid building unused or invisible systems

---

## 15. First Milestone (Reset)

### Objective

User can download a file from the UI

### Requirements

* Input URL
* Start download
* Show progress
* Save file

### Constraints

* No chunking
* No advanced architecture
* Keep implementation simple

---

## Final Note

The success of this project depends on:

* Continuous visible progress
* Tight feedback loops
* Avoiding unnecessary complexity early

The expectation is not perfection —
The expectation is **consistent, working progress**
