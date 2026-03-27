import times, math, tables
import ../libs/miniecs/miniecs

# =========================
# Benchmark template
# =========================
include "benchmarks.nim"

const SAMPLE = 1000
const WARMUP = 1
const ENTITY_COUNT = 10000

# =========================
# Components
# =========================

type
  Position = object
    x, y: float32

  Velocity = object
    x, y: float32

  Acceleration = object
    x, y: float32

  Tag = object

  Health = object
    hp: int

# =========================
# Benchmarks
# =========================

proc runMiniBenchmarks() =
  var suite = initSuite("MiniECS Operations")

  # ------------------------------
  # Create entity
  # ------------------------------
  suite.add benchmarkWithSetup(
    "mini_create_entity",
    SAMPLE,
    WARMUP,
    (
      var ecs = newMiniECS()
      var ents: seq[Entity]
    ),
    (
      for i in 0..<ENTITY_COUNT:
        var e = ecs.newEntity()
        e.addComponent(Position(x: 1.0, y: 1.0))
        e.addComponent(Velocity(x: 1.0, y: 1.0))
        ents.add e
    )
  )
  showDetailed(suite.benchmarks[0])

  # ------------------------------
  # Delete entity
  # ------------------------------
  suite.add benchmarkWithSetup(
    "mini_delete_entity",
    SAMPLE,
    WARMUP,
    (
      var ecs = newMiniECS()
      var ents: seq[Entity]
      for i in 0..<ENTITY_COUNT:
        var e = ecs.newEntity()
        e.addComponent(Position(x: 1.0, y: 1.0))
        e.addComponent(Velocity(x: 1.0, y: 1.0))
        ents.add e
    ),
    (
      for i in 0..<ENTITY_COUNT:
        destroy(ents[i].getID(), ecs)
    )
  )
  showDetailed(suite.benchmarks[1])

  # ------------------------------
  # Add component
  # ------------------------------
  suite.add benchmarkWithSetup(
    "mini_add_component",
    SAMPLE,
    WARMUP,
    (
      var ecs = newMiniECS()
      var ents: seq[Entity]
      for i in 0..<ENTITY_COUNT:
        ents.add ecs.newEntity()
    ),
    (
      for i in 0..<ENTITY_COUNT:
        addComponent(ents[i].getID(), Position(x: 1.0, y: 1.0), ecs)
    )
  )
  showDetailed(suite.benchmarks[2])

  # ------------------------------
  # Remove component
  # ------------------------------
  suite.add benchmarkWithSetup(
    "mini_remove_component",
    SAMPLE,
    WARMUP,
    (
      var ecs = newMiniECS()
      var ents: seq[Entity]
      for i in 0..<ENTITY_COUNT:
        var e = ecs.newEntity()
        e.addComponent(Position(x: 1.0, y: 1.0))
        ents.add e
    ),
    (
      for i in 0..<ENTITY_COUNT:
        removeComponent(ents[i].getID(), Position, ecs)
    )
  )
  showDetailed(suite.benchmarks[3])

  # ------------------------------
  # Add + Remove component
  # ------------------------------
  suite.add benchmarkWithSetup(
    "mini_add_remove_component",
    SAMPLE,
    WARMUP,
    (
      var ecs = newMiniECS()
      var ents: seq[Entity]
      for i in 0..<ENTITY_COUNT:
        ents.add ecs.newEntity()
    ),
    (
      for i in 0..<ENTITY_COUNT:
        let id = ents[i].getID()
        addComponent(id, Position(x: 1.0, y: 1.0), ecs)
        removeComponent(id, Position, ecs)
    )
  )
  showDetailed(suite.benchmarks[4])

  # ------------------------------
  # Iteration
  # ------------------------------
  suite.add benchmarkWithSetup(
    "mini_iteration",
    SAMPLE,
    WARMUP,
    (
      var ecs = newMiniECS()
      for i in 0..<ENTITY_COUNT:
        var e = ecs.newEntity()
        e.addComponent(Position(x: 1.0, y: 1.0))
        e.addComponent(Velocity(x: 1.0, y: 1.0))
    ),
    (
      for id, pos, vel in ecs.allWith(Position, Velocity):
        pos.x += vel.x
        pos.y += vel.y
    )
  )
  showDetailed(suite.benchmarks[5])

  # ------------------------------
  # Read
  # ------------------------------
  var s = 0'f32
  suite.add benchmarkWithSetup(
    "mini_read",
    SAMPLE,
    WARMUP,
    (
      var ecs = newMiniECS()
      var ents: seq[Entity]
      for i in 0..<ENTITY_COUNT:
        var e = ecs.newEntity()
        e.addComponent(Position(x: 1.0, y: 1.0))
        ents.add e
    ),
    (
      for i in 0..<ENTITY_COUNT:
        s += getComponent(ents[i].getID(), Position, ecs).x
    )
  )
  showDetailed(suite.benchmarks[6])

  # ------------------------------
  # Write
  # ------------------------------
  suite.add benchmarkWithSetup(
    "mini_write",
    SAMPLE,
    WARMUP,
    (
      var ecs = newMiniECS()
      var ents: seq[Entity]
      for i in 0..<ENTITY_COUNT:
        var e = ecs.newEntity()
        e.addComponent(Position(x: 1.0, y: 1.0))
        ents.add e
    ),
    (
      for i in 0..<ENTITY_COUNT:
        getComponent(ents[i].getID(), Position, ecs).x = s
    )
  )
  showDetailed(suite.benchmarks[7])

  suite.showSummary()

if isMainModule:
  runMiniBenchmarks()
