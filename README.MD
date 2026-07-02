
# State Of The Project

## Summary

Faktory currently has a solid gameplay-systems foundation. The project is no longer just raw data: it has working definitions, runtime state, managers, deterministic resource node generation, inventory, production, machines, player state, discovery, rendering, and save/load.

The next step is turning those systems into a smooth playable loop.

Current intended loop:

```text
Move player
→ Discover resource nodes
→ Mine resources
→ Use resources in machines
→ Produce items
→ Progress through milestones
→ Save/load game state
```

## Current Architecture

### Definitions

Static `.tres` data loaded by `DataManager`.

```text
ItemDefinition
RecipeDefinition
MachineDefinition
NodeDefinition
MilestoneDefinition
```

### Runtime State

Mutable game state.

```text
PlayerState
MachineState
NodeState
```

### Managers

```text
DataManager
InventoryManager
SaveManager
MapManager
ProductionManager
MachineManager
ProgressionManager
PlayerManager
EventBus
```

Overall, this architecture is good. Each manager mostly owns one domain.

## What Is Done

### Data

Done:

- Items load from data files.
- Recipes load from data files.
- Machines load from data files.
- Nodes load from data files.
- Milestones load from data files.
- Basic validation exists for missing ids and invalid item references.

Current content:

```text
4 items
1 recipe
3 machines
2 node types
1 milestone
```

### Inventory

Done:

- Add items.
- Remove items.
- Check item amounts.
- Check and remove costs.
- Save/load inventory.
- Inventory changed events.

### Production

Done:

- Check if a recipe can be crafted.
- Consume recipe inputs.
- Grant recipe outputs.
- Read recipe processing time.
- Manual/debug crafting works.

### Machines

Done:

- Create machines.
- Assign recipes.
- Start machines.
- Progress machines over time.
- Finish machines.
- Grant outputs on completion.
- Auto-restart while inputs remain.
- Stop when inputs are exhausted.
- Save/load machine state.

Current simplification:

- Machines consume from global inventory.
- Machines output to global inventory.
- There are no local machine buffers yet.

That is fine for now.

### Map And Nodes

Done:

- Seeded world generation exists.
- Same seed gives same generated world.
- Node types are selected using `spawn_weight`.
- Node positions are generated.
- Node capacities come from `NodeDefinition`.
- Nodes can be discovered.
- Discovered nodes can be queried.
- Nodes can be mined.
- Exhausted nodes cannot be mined again.
- Map/node state can be saved and loaded.

### Discovery

Done:

- Player position can trigger node discovery.
- Discovered nodes are rendered.
- Discovery persistence is implemented through `MapManager` save/load.

### Player

Done:

- Player has runtime state.
- Player position is tracked by `PlayerManager`.
- Player discovery radius exists.
- Player state can save/load.
- `PlayerMarker` is a `CharacterBody2D` control with basic keyboard movement.

### Rendering

Done:

- World scene exists.
- Player marker exists.
- Node marker exists.
- World renderer renders discovered nodes.
- Player movement can trigger discovery/render refresh.

Still prototype-level visually, but functionally moving in the right direction.

### Save System

Done:

`SaveManager` coordinates:

```text
player
inventory
world/map nodes
machines
progression
```

This is the right role for `SaveManager`: coordinate, not own gameplay logic.

## What Is Missing

### Core Gameplay

Missing:

- Interact button.
- Manual mining from the world.
- Selecting nearby resource nodes.
- Machine placement.
- Machine selection.
- Recipe assignment UI.
- Inventory UI.
- Milestone UI.

Right now many systems work through debug tests, but not yet through player-facing gameplay.

### World Generation V2

Still missing:

- Data-driven generation settings.
- Configurable node count.
- Configurable map size.
- Minimum spacing between nodes.
- No duplicate positions.
- Biomes/regions.
- Better spawn rules.

Current generation is good enough for testing, but still hardcoded.

### Camera And Movement

In progress/mostly done:

- CharacterBody2D player movement.
- Camera follow.
- Discovery triggered by movement.

Need to finish and stabilize this before building more UI.

### Progression Integration

Progression exists, but does not fully gate gameplay yet.

Missing:

- Starting unlocks.
- Locked recipes preventing use.
- Locked machines preventing placement.
- Milestone completion from UI.
- Requirement consumption.
- Unlock feedback.

### Machine Gameplay

Machines work internally, but need world integration.

Missing:

- Placing machines on map.
- Rendering placed machines.
- Selecting machines.
- Showing progress.
- Starting/stopping from UI.
- Placement validation.

### Save Hardening

Save/load works, but needs stronger tests later.

Missing:

- Save version migration.
- Corrupt save handling.
- Active machine save/load verification.
- Full game-state save/load test.
- Validation of loaded ids.

## Architecture Issues

### 1. Generation Is Still Hardcoded

Node count and map bounds are still hardcoded.

Later, create:

```text
WorldGenerationSettings
```

with:

```text
node_count
min_position
max_position
```

## Proposed Roadmap

### 1. Clean Up Current Foundation

Do this before adding bigger features.

- Remove or comment `CraftingJob`. DONE
- Remove `_generate_test_nodes()`. DONE
- Sort node ids in weighted generation. THIS NEEDS REVIEW - CHECK
- Remove noisy discovery logs. DONE
- Align player default values. DONE
- Keep all debug tests passing. DONE, ALL PASSING

### 2. Finish Player Movement

Goal:

```text
CharacterBody2D
→ keyboard movement
→ PlayerManager position update
→ discovery triggered by movement
→ camera follows player
```

This is mostly done, it needs review for improvements, exported vars and any overall improvements in the camera for the future

### 3. Add Player Interaction

Next playable feature:

```text
Move near discovered node
→ press interact
→ mine node
→ inventory updates
```

This is done, with debug and logs from node mining interaction.

### 4. Add Basic UI

Minimal UI first:

- Inventory readout.
- Nearby node info.
- Selected machine info.
- Save/load buttons or keys.

No need for polish yet.

### 5. Add Machine Placement

Next major step:

```text
Choose machine
→ place on tile
→ save machine
→ render machine
```

This connects machines to the world.

### 6. Add Machine Selection And Recipe Assignment

Then:

```text
Click/select machine
→ assign recipe
→ start production
→ show progress
```

Your backend already supports this well.

### 7. Integrate Progression

After machines are playable:

- Gate recipes.
- Gate machines.
- Complete milestones.
- Unlock new content.

Progression will feel meaningful once production exists in-world.

### 8. Upgrade World Generation

Once gameplay needs are clearer:

- Add generation settings resource.
- Add map size config.
- Add node count config.
- Add spacing rules.
- Add no-overlap checks.

### 9. Improve Save/Load Robustness

After more systems exist:

- Test full game save/load.
- Test active machines mid-progress.
- Test player position.
- Test discovered nodes.
- Test placed machines.
- Add migration handling.

### 10. Expand Factory Depth

Only after the basic loop works:

- More items.
- More recipes.
- More machines.
- Miners attached to nodes.
- Belts or logistics.
- Power/fuel.
- Machine buffers.

## Recommended Immediate Next Step

The best next implementation order is:

```text
1. Clean small architecture leftovers DONE
2. Finish CharacterBody2D movement + camera follow DONE (NEEDS REVIEW)
3. Trigger discovery from movement (NODES APPEAR ON PLAYER DISCOVERY RADIUS COLISSION WITH A NODE'S COORDS)
4. Add interact-to-mine
5. Add machine placement
```

Once this works, the game has a real foundation:

```text
Explore
→ discover
→ mine
→ craft
→ produce
→ save/load
```