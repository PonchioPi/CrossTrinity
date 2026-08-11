# CrossTrinity
Un addon pour constituer un moteur data-driven pour des jeux d'actions et/ou d'expérimentation combinatoire.

## Arborescence

```text
res://
├─ addons/
├─ autoload/
│  ├─ [] game_database.gd
│  ├─ [] debug_console.gd
│  ├─ [] event_bus.gd
│  ├─ [] timeline.gd
│  ├─ [] interaction_engine.gd
│  ├─ [] conflict_mediator.gd
│  └─ [] save_manager.gd
├─ core/
│  ├─ value_objects/
│  │  ├─ [] conflict_batch.gd
│  │  ├─ [] stat_block.gd
│  │  ├─ [] reaction_context.gd
│  │  └─ [] tag_registry.gd
│  ├─ [] rule_resolver.gd
│  ├─ [] tag_query.gd
│  ├─ [] event_types.gd
│  ├─ [] effect_applier.gd
│  └─ [] event_consumer.gd
├─ data/
│  ├─ tags/
│  │  └─ [] tag_data.gd
│  ├─ elements/
│  │  └─ [] element_data.gd
│  ├─ materials/
│  │  └─ [] material_data.gd
│  ├─ statuses/
│  │  └─ [] status_data.gd
│  ├─ actions/
│  │  └─ [] action_data.gd
│  ├─ spells/
│  │  └─ [] spell_data.gd
│  ├─ recipes/
│  │  └─ [] recipe_data.gd
│  ├─ rules/
│  │  └─ [] rule_data.gd
│  ├─ curves/
│  │  └─ [] property_profile.gd
│  ├─ effects/
│  │  └─ [] effect_data.gd
│  └─ events/
│     └─ [] event_data.gd (analogue de effect_data.gd car les effets sont aussi 
│           des évênements)
├─ entities/
│  ├─ actor/
│  │  ├─ [] actor_state.gd
│  │  ├─ [] actor_inventory.gd
│  │  └─ [] actor_knowledge.gd
│  ├─ item/
│  │  ├─ [] item_stack.gd
│  │  └─ [] item_instance.gd
│  ├─ material/
│  │  ├─ [] material_stack.gd
│  │  └─ [] material_instance.gd
│  └─ status/
│     ├─ [] status_container.gd
│     └─ [] status_instance.gd
├─ systems/
│  ├─ combat/
│  │  ├─ [] combat_context.gd
│  │  ├─ [] damage_resolver.gd
│  │  └─ [] combat_system.gd (intègre combat_resolver.gd)
│  ├─ craft/
│  │  ├─ [] forge_system.gd
│  │  ├─ [] recipe_resolver.gd
│  │  └─ [] craft_system.gd (intègre craft_resolver.gd)
│  ├─ magic/
│  │  ├─ [] spell_resolver.gd
│  │  ├─ [] spell_builder.gd
│  │  └─ [] magic_system.gd (intègre magic_resolver.gd)
│  ├─ status/
│  │  ├─ [] status_tick_handler.gd
│  │  ├─ [] status_resolver.gd
│  │  └─ [] status_system.gd
│  ├─ timeline/
│  │  ├─ [] event_queue.gd
│  │  ├─ [] scheduled_event.gd
│  │  └─ [] timeline_system.gd
│  └─ rythm/
│     ├─ [] rythm_context.gd
│     ├─ [] note_resolver.gd
│     └─ [] rythm_system.gd (intègre rythm_resolver.gd)
├─ scenes/
│  ├─ main/
│  ├─ world/
│  ├─ combat/
│  ├─ ui/
│  └─ debug/
├─ ui/
│  ├─ widgets/
│  ├─ panels/
│  └─ overlays/
├─ tools/
│  ├─ editors/
│  ├─ generators/
│  ├─ importers/
│  └─ validators/
├─ tests/
└─ [x] README.md
```
