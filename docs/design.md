# Pantry Planner - Design

## Overview

-TODO-

## Stack

The architecture of this application is divided into 3 distinct layers, kept divided by their respective technologies

### Database

- PostgreSQL

### Backend

- Java 21 (Temurin LTS)
- Maven
- Spring Boot 4.1.1
  - Spring Web
  - Spring Data JDBC
  - PostgreSQL Driver

**Spring Data JDBC over JPA.** Chosen deliberately to keep SQL visible while
learning Spring. Although JPA is more standard, it hides query generation.

### Frontend

-TBD-

## Domain Model

-TBD-

## Units and measurement

When a user defines an ingredient, they must specify at least 1 of the three measurement categories:

- **Count**: eggs, cloves, cans
- **Mass**: grams, pounds
- **Volume**: millilitres, fluid ounces

Within a category, conversion is universal (1 kg = 1000 g), however for an ingredient to convert between measurement types,
the user must specify the conversion. When specifying more than one type of measurement, the conversion rate **must** also be specified.

Within the application itself, Count is stored as integers units, Mass is stored as grams, and Volume is stored as millilitres.
When a recipe may ask for an amount that is not of these units, the user can either use one of the predefined conversions (e.g. 1 lb -> 453.592 g),
or to a user defined conversion. This includes custom conversions of the same measurement type, but also different measurement types if, and only if the user
has specified the conversion rate.
The user may also choose to display the units of measurements in imperial or metric format, however that does not change how they are stored in the application.

## Scaling

By default, the application uses only the initially defined recipe (base recipe) and serving size (base serving size), however the user may specify other serving sizes. Newly specified serving sizes will derive ingredient amounts from the base recipe, then scale the amount relative to the base serving size.
(e.g 2 Servings: 1 egg --> 4 Servings: 2 eggs).
However, a user may declare their own amount to an ingredient on serving size, which will prevent the amount from automatically scaling to unit proportions that don't conform to reality.
This means that ingredients in a recipe are either:

- **Derived**: follows the base recipe, and updates when the base changes
- **Fixed**: the user's defined value, unaffected by any base changes or calculations.

Derived and fixed ingredients are identified graphically within the UI while editing so the user can distinguish which ingredients will scale.

**Known consequence:** a fixed value can become stale if a base recipe changes. The UI labeling lets the user notice and
correct it. Automatic resolution would require guessing at the user's intent.

## Constraints

- Density is a property of the substance, not the unit.
- The scalability of an ingredient within a recipe can be suggested, but the divisibility or scalability can never guarantee real world accuracy. Fixed ingredients allow users to manually reflect this discrepancy
- Only units defined within the system can be used. The application can't use a unit unless it has been declared and specified.

## Not yet designed

2. Is "flour" one ingredient, or are "all-purpose flour" and "bread flour" separate? This affects whether a recipe calling for flour can draw from a pantry holding bread flour.

3. What does a meal-prep record refers to when its recipe is later edited. If you cooked something last week and then change the recipe, does the history show what you actually made or what the recipe says now? This is the interaction between "recipes can change" and "we keep records."

4. Recipe import from websites.
