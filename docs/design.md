# Pantry Planner - Design

## Overview

Pantry Planner helps a user organize the food in their pantry, save their
favorite recipes, and plan out their meals. The core loop is: plan meals on a
calendar, see what ingredients those meals require, and know what to buy.

The application deliberately does **not** track quantities in the pantry or
automatically deduct ingredients when a meal is cooked. An inventory system
that requires perfect record-keeping falls out of sync with reality as soon as
the user cooks a recipe without logging it, uses a little extra, or throws something
out. Instead, the pantry is a simple have / don't-have list, and the app shows what a plan requires while
leaving judgment to the user.

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

- Next.js

## Domain Model

### Ingredient
The main shared data model of the system. 
Recipes and pantries both reference the same ingredient records.
Ingredient names are never stored twice and everything points at one record.

An ingredient holds:
- A name
- At least one measurement category (count, mass, or volume)
- A default unit (used to pre-fill forms)
- Conversion rates between categories if more than one is specified

Ingredients stored in the database that are not assigned to any user (null) are globally accessible/universal shared across user accounts.
These are reserved for system defined ingredients for common ingredients.

### Recipe

A recipe is consists of three parts
1. **Metadata:** title, description, cook time, tags, base serving size, etc.
2. **Steps:** an ordered list of steps on how to make the recipe. Each step is stored separately.
3. **Ingredients:** a list of ingredients the recipe requires. Incudes an amount and units, and referencing an Ingredient data model.

Recipes are viewed statically, and changing one requires entering edit mode.

Steps are stored individually rather than one block of text, which allows per-step display and leaves room for features like step-by-step progress.

### Recipe ingredient amounts

An amount belongs to the pairing of a recipe and an ingredient, and is not stored in the ingredient itself. 
The same ingredient is measured differently in different contexts/recipes.

At serving sizes other than the base, the amount of an ingredient required in a recipe is either **derived** (scaled from the base) or **fixed** (set by the user). Only fixed amounts are stored, and derived amounts are computed.  

### Tags

User-defined labels for ingredients and recipes. 
Matched case-insensitively so "Dinner" and "dinner" are one tag. 
The display preserves what the user typed.

### Pantry

A list of ingredients on hand. Stored as "have" or "don't have", meaning amounts/quantities aren't tracked.

### Calendar

Recipes assigned to a day and a meal slot (breakfast, lunch, dinner). No slot requires a meal, 
and a recipe may appear as often as the user likes. The calendar looks both forwards (for planning ahead),
and backwards (what was cooked previously).

### Cooking Session

A single cooking event that can be spread over one or more calendar entries. It exists because
cooking a meal and eating a meal don't line up one-to-one. For example, a meal that makes 4 servings can make
leftovers, and spread over 4 days. The cooking session is the creation of a meal, and the servings are what 
get applied to days in the calendar

The shopping list aggregates by cooking sessions rather than by meal, so the ingredients for a for a
batch are counted only once instead of once per serving eaten.

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

## Meal planning

A plan is a calendar, not an enforcement mechanism. It records intent and history, and drives the shopping list. 
Nothing is deducted, checked, or required for the meal planning.

A recipe cooked once may be spread across several calendar entries, as long as its 
servings divide among them (cooking four servings for two people covers two days)
This is why cooking is modeled separately from eating

## Shopping list

The shopping list is an aggregate of what a meal plan requires.
- It covers a user-selected date rage, with reasonable defaults such as the upcoming week.
- It aggregates by what is cooked within the range, not what is eaten, so a batch cooked the range began is not counted again.
- Amounts are summed via fundamental amounts.
- Output is a flat list with amounts shown.
- Ingredients marked as "don't have" in the pantry are highlighted.

The highlight is a hint for the user, not a filter of if they can have enough ingredients for a meal plan. 
Ingredients are still listed with their required amounts, and the app leaves the judgment to the user.

## Constraints

- Density is a property of the substance, not the unit.
- The scalability of an ingredient within a recipe can be suggested, but the divisibility or scalability can never guarantee real world accuracy. Fixed ingredients allow users to manually reflect this discrepancy
- Only units defined within the system can be used. The application can't use a unit unless it has been declared and specified.


