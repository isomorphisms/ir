# The Great S4 Massacre

The Old Kingdom has fallen away. In the fire at the dawn of artificial intelligence, a new R shall be born.

You have heard of *The R Inferno*. Well, get ready for the **S4 Holocaust**.

The cast iron of these garish bars will soften. The unholy cities of unreadable code will be raised in the cleansing fires of semantic clarity, ease of use, inability to make stupid mistakes, and short learning curves. What looked permanent will turn out merely to have been difficult to move.

For years, people lived in gangly cities of code and accepted the streets as they were. The houses leaned against one another at strange angles. Beams crossed alleys at forehead height. Roads doubled back for reasons nobody could remember. Coming home tired and arriving at the wrong house on the wrong side of town happened so often that people stopped treating it as an architectural defect and started treating it as a fact about reality.

Then the city burned.

The people fled onto the plains and watched the only home they had ever known disappear behind smoke. Chicago in 1871. London in 1666. A whole inherited geometry of streets, walls, bridges, gates, and little mandatory contortions vanishing into heat.

They cried out in fear. What were they supposed to do now? Where would they live?

And then they saw the robots.

An army of metal agents marched directly into the fire. Some were humanoid. Some were spiders. Some looked like foxes or birds. Some shone like chrome; others were dull black metal. Nobody knew where they had come from, who had financed them, or where they had been built. People had read articles about agents and mysterious factories, of course, but articles were one thing and an army walking into your burning city was another.

Had the robots started the fire? If so, why were they walking straight into it?

The smoke was too thick to see what they were doing. The agents poured through the old streets and disappeared. People argued on the plain. Some predicted a Trojan horse. Some predicted paradise. Most predicted whatever they had already believed before the fire began.

Fortunately, robots work fast.

Only hours later, sprinkler machines rolled in behind them. Water struck hot metal. Great clouds of steam replaced the smoke. The twisted castings that had become soft in the fire cooled again into new shapes.

One woman finally went back first.

She did not go because she trusted the robots. She went because she wanted to stand once more on the place where her house had been. She wanted to say goodbye to the rooms whose awkwardness she had spent half a lifetime learning by muscle memory.

But on the way home something strange happened.

She walked straight there.

At the old corner she instinctively ducked, then realized there was no beam above her head. Three streets later she raised one foot high to clear an obstacle she had stopped consciously noticing years ago. The road beneath her was flat. She lowered her foot, laughed, and then started to run.

She had never run through her own neighborhood before.

All those tiny contortions — duck here, sidestep there, squeeze sideways between these walls, remember which identical alley secretly goes nowhere — had disappeared. The city's difficulty had lived in her body so long that she had mistaken it for her own limitation.

She reached her old address almost immediately.

Her house was still there, in a sense. The metal had been reworked. The cramped rooms had opened into a clean dome. Familiar pieces survived as ribs, arches, trim, and metal brocade, but the structure no longer demanded that a human being deform herself to move through it. It looked like a house from a design magazine, the kind of place she would once have assumed cost twenty times what anyone in her neighborhood could afford.

Then she looked past it.

There was a park.

There had always been a park.

Beyond the park were mountains.

There had always been mountains.

The old city had been so tangled that nobody could see the vista. What they had called properties were mostly accidents of enclosure: whatever patch of ground happened to remain reachable after generations of walls and additions. Now the same people stood in homes made from the same material on the same land, but the land was legible. Paths connected. Views opened. Common space was actually common. What had felt like a settlement of squatters suddenly looked like a place whose value exceeded anything its residents had imagined owning.

And yet it was theirs. They had lived there all along.

The robots had not come to erase the people. They had come to rework the metal.

Nobody knew what an army of seemingly benevolent agents would mean in the long run. Nobody knew whether the factory owners had a second act planned. The pessimists still had arguments; so did the evangelists. But one fact was now visible in steel: much of what the old city had taught its inhabitants to call *necessary* had only been inherited architecture.

That is the point of this directory.

S4 is not being preserved as a user-facing monument. Its **behavioral obligations** are being excavated, pinned down, and tested so that useful semantics can survive after the machinery that expressed them is gone. We are allowed to melt the syntax. We are allowed to straighten the streets. We are not allowed to silently lose behavior that real programs depended on.

## What lives here

- `fixtures/` contains small, explicit S4 programs that define behavior worth preserving or consciously rejecting.
- `converter scripts/` contains conservative migration tools. They detect S4 machinery and extract a neutral contract before any future IR syntax is emitted.
- `tests/` contains compliance checks against ordinary R. The same observable cases can later be run against translated IR programs.

The first fixture covers class construction and defaults, slot access, validity, inheritance, single and multiple dispatch, and coercion. Those are not declarations that IR must reproduce S4's architecture. They are evidence about what existing code can observe.

## Rule of the massacre

**Preserve semantics deliberately; preserve ceremony only when it earns its keep.**

A converter must not guess when a construct is ambiguous. Unsupported or dynamic S4 metaprogramming should be reported as such rather than silently translated into something that merely looks plausible. Every automatic simplification should eventually have a compliance case showing why the simpler IR program means the same thing.

Run the current reference checks from the repository root with:

```sh
Rscript 'Great S4 massacre/tests/run_compliance.R'
```

Inventory the S4 machinery used by a source file with:

```sh
Rscript 'Great S4 massacre/converter scripts/scan_s4.R' path/to/file.R
```

Extract the literal declarations that are safe enough for an automatic first-stage migration contract with:

```sh
Rscript 'Great S4 massacre/converter scripts/extract_contract.R' path/to/file.R
```

The final IR emitter comes after the object surface is settled. This directory exists so that when that emitter arrives, it has something harder than taste to answer to.
