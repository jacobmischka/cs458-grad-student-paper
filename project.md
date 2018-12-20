---
title: Graduate Student Project
author: Jacob Mischka
date: \today{}
classoption:
	- titlepage
toc: true
toc-title: Table of Contents
geometry: margin=2cm
fontsize: 12pt
linkcolor: blue
citecolor: blue
bibliography: project.bib
reference-section-title: References
header-includes:
	- \usepackage{setspace}
	- \doublespacing
---

\maketitle

\newpage

# Technology

In general, there are four primary types of power dissipation that plague a
computer system: Dynamic switching power, short circuit power,
static power, and leakage power [@burd94cmos].

### Dynamic power

The primary source of power dissipation in a CMOS circuit is the dynamic, or
switching power, which is the energy required to charge the nodes that make up
the circuit in order to toggle a switch [@burd1995energy; @moyer2001low].

Dynamic power is defined as
\( P_{dynamic} = C \cdot V_{dd} \cdot V_{swing} \cdot \alpha \cdot f \),
where \( C \) is the system's capacitance, \( V_{dd} \) is the supply voltage,
\( V_{swing} \) is the change in voltage level of the switched capacitance, \(
\alpha \) is the activity factor, and \( f \) is the system's clock frequency.

Because the supply voltage and voltage change are effectively the same in most
systems, the above can be simplified by combining the two:
\( P_{dynamic} = C \cdot V_{dd}^{2} \cdot \alpha \cdot f \).
Thus, decreasing a system's voltage has a quadratic effect on reducing dynamic
power usage. Additionally, as frequency and voltage are so closely tied, the
two can be reduced simultaneously, resulting in a cubic improvement in power
dissipation.

### Short-circuit power

In addition to the power dissipated by switching the components between active
and inactive states in a computer system, there is a period in between those
states in which power is lost. In a CMOS inverter, its NMOST transistor
conducts when the input is high, and the PMOST transistor conducts when the
input is low. However, when transitioning between states, there exists a time
during which both transistors conduct, causing a short circuit to flow
directly from power supply to ground for as long as the input voltage is at a
certain range that causes both transistors to be active [@1052168].

### Static power

Contrary to dynamic power dissipation, which is caused by the active functions
performed by the various parts of a computer system, static and leakage power
dissipations are caused simply by the existence of components within the system.

Fortunately, static power dissipation plays a relatively small role in the
CMOS-based designs that dominate the computing landscape today, as static
current is not drawn by a CMOS gate [@burd1995energy; @moyer2001low].

### Leakage

Finally, while traditional static power issues have largely disappeared in
modern systems, the issue of power wasted by leakage has arisen in its place.
The two primary types of leakage plaguing modern systems are sub-threshold
leakage and gate leakage [@Kaxiras2008 pp. 134].

Gate leakage is a largely process-level issue which arises from electrons
tunneling through the insulators between logic gates. As chips become smaller,
the insulators separating the gate terminals from the transistor channels must
scale accordingly. However, the smaller they become, the easier it is for
electrons to tunnel through them, wasting power [@Kaxiras2008 pp. 137].

Sub-threshold leakage is the power dissipated by a transistor that is intended
to be in the inactive state, though is leaking a small amount of current to
ground even when the supply voltage is below the switching threshold voltage.
The (complicated) formula describing the subthreshold leakage current is
\(I_{s0} (1 - e^{\frac{-V_{ds}}{v_t}}) e^{\frac{V_{gs}-V_{T}-V_{off}}{n \cdot
v_{t}}}\). While too complex to warrant describing in full in this paper, the
important takeaways relevant to computer architecture and design decisions to
reduce leakage power dissipation is that the power wasted by leakage relies
primarily on the four following variables: [@Kaxiras2008 pp. 134-136]

- \(I_{s0}\), transistor geometry: aspect ratio and size of transistors
- \(V_{ds}\), voltage differential between drain and source
- \(V_{gs}\), voltage differential between gate and source
- \(V_{T}\), threshold voltage
- \(T\), temperature

As the quest for power-efficiency has thus far been dominated by research into
reducing switching power, and as the threshold voltage of computer systems has
decreased in order to improve performance, the percentage of overall power
dissipated by leakage has risen to 20--40% [@Kaxiras2008 pp. 133], and
is expected to continue rising, with a chip's leakage power increasing about 5
times each generation [@782564].

# Computer Organization and Architecture

In complementary metal-oxide-semiconductor (CMOS) circuits, the two primary
types of power dissipation are dynamic power and leakage.

## Techniques to reduce dynamic power

For the majority of the history of CMOS-based computer systems, dynamic or
switching power has contributed to the majority of the overall power
dissipation [@burd1995energy].

### Dynamic Voltage and Frequency Scaling

As illustrated in the formulas above, a system's voltage has a quadratic effect
on the amount of power consumed. While performance improvements often bring
along with it increased voltage requirements, Dynamic Voltage Scaling takes
advantage of the fact that a system is rarely required to operate at peak
performance in practice [@Pillai:2001:RDV:502059.502044]. By dynamically
reducing supply voltage when the system does not require maximum computation
performance, power consumption can be drastically reduced (up to 10 times)
without greatly affecting the overall performance of the system
[@Burd:2000:DID:344166.344181].

@Pillai:2001:RDV:502059.502044 present several algorithms to apply DVS to
embedded systems in which real-time deadline guarantees are required, thus
limiting the threshold to which system performance can be reduced. Dubbed
RT-DVS, voltage scaling is integrated into rate monotonic and
earliest-deadline first schedulers via three methods. The first, Static
Voltage Scaling, simply applies the lowest possible operating frequency---and
associated voltage---that guarantees that all deadlines are met in the worst
case using predetermined computation time values. The second, Cycle-conserving
RT-DVS, begins operating at the frequency necessary to complete all scheduled
tasks within their worst-case deadlines, and decreases frequency and voltage
when a task is completed. In order to guarantee that subsequent invocations
meet their worst-case time guarantees, the frequency is increased again upon
task release, but the other tasks still being computed before then are able to
complete using the reduced frequency, resulting in overall power savings as
the frequency and voltage is further reduced for each completed task. In the
final method, Look-Ahead RT-DVS, the system begins operating at a lower
frequency and will then later scale back up only if it appears that later
deadline guarantees will not be met. Essentially analogous to procrastination,
the scheduler optimizes for completion of the task with the earliest deadline,
deferring work for later deadlines after the task has been completed, and
increasing frequency when deadlines approach with work remaining.

The IpARM [@Pering:2000:VSI:344166.344530] instead maintains real-time
guarantees when utilizing DVFS by adding a level of buffering to outputs.
Scheduling of speed and voltage scaling is performed at regular intervals,
such as when threads are introduced or removed or at the end of a deadline.
The scheduler calculates the minimum speed and voltage required to complete
the task in the required time. By allowing deadlines to be missed using the
buffers, the voltage scheduler can optimize for the average-case workload
instead of worst-case, reducing energy usage.

#### Hardware DVFS

In addition to system-level voltage and frequency scaling performed by
software, hardware techniques to accomplish the same task have been
investigated as well. In their revolutionary Razor design, @ernst2003razor
have developed hardware components that are able to scale the voltage and
frequency of a system even lower. Specially designed Razor flip-flops are
inserted into circuits that monitor the error rate caused by scaling the
voltage of the system too low.

Traditional DVFS techniques ensure correctness by operating at a _critical
voltage_, particularly chosen such that the system will behave correctly even
under worst-case scenarios of process and environmental conditions. While
correct results are of course necessary, optimizing for the worst-case results
in power waste, as these catastrophic conditions rarely all occur
simultaneously. By utilizing this _in-situ_ error detection, system voltage
can be reduced to its absolute minimum; the system's voltage is optimally
tuned right at the point at which errors begin to occur. These errors are
detected using a _shadow latch_ within the special flip-flops which is
controlled using a delayed off-cycle clock pulse. When the value in the main
flip-flop (captured at the normal clock rate) differs from that contained
within the delayed latch, the circuit was unable to complete its function in
the required time, and an error signal is thrown by the flip-flop.

Once an error is detected by the flip-flop, recovery is performed using
counterflow pipelining. The erroneous pipeline stage sends a _bubble_ signal
to subsequent stages, indicating that an error has occurred and the pipeline
slot is empty. The pipeline is then flushed using the _flush train_. In the
following cycle, the correct value captured by the shadow latch is inserted
into the pipeline, execution continues using the now-correct result. These
detection and recovery mechanisms have been shown to incur only a 3.1%
increase in power requirements themselves, and Razor adders have been shown to
operate with 42% less energy with at most 2.5% reduction in pipeline
throughput.

The authors improved their design a few years later with Razor II [@4735568],
which simplifies the design by utilizing architectural replay instead of the
counter-flow propagation and bubbling used in its predecessor. This allows
the Razor II flip-flops to focus only on the _detection_ of errors and
releases them from the responsibility of correcting them, reducing the number
of transistors required from 76 in Razor I to only 47---or only 39 if the
detection clock is shared between them.

While forward progress is not _guaranteed_ with this technique as it is in
the initial implementation, the system works around this issue by implementing
error thresholds. A predefined number of errors is declared---the "replay
limit"---at which point the system's frequency is simply increased in order to
ensure successful completion. While such an increase will result in more power
usage, in practice most errors---around 60%---simply disappear in subsequent
attempts without any voltage adjustments. The authors have been able to obtain
33% energy savings over traditional DVS techniques using Razor II.

#### Memory

In a study on power saving techniques in what they call online data-intensive
(OLDI) services, such as serving web search results,
@Meisner:2011:PMO:2024723.2000103 highlight the importance of utilizing
_active_ low-power modes. While a server with only 10% load draws upwards of
50--60% of its peak power, full-system _idle_ low power modes are not
well-suited to OLDI services because they have a large dynamic range---while
rarely at maximum capacity, they are also essentially never idle. While DVFS
techniques provide such a mechanism for a system's processor, those power
savings are expected to reduce in the future as the gap between nominal supply
and threshold voltages shrink [@Kaxiras2008 pp. 182]. Additionally, as modern
CPUs have extensive clock-gating mechanisms built in, devising additional power
gating modes do not provide much additional benefit, requiring investigation
into a DVFS-like solution for a system's memory units.

@6178197 illustrate this application in what they call MemScale, a methodology
of applying active low-power modes to a system's memory. Exploiting the fact
that lowering the frequency of memory systems affects bandwidth more than
latency (a 800MHz to 400MHz reduction shows a 50% hit to bandwidth but only a
10% increase in latency), the technique is well-suited to use cases requiring a
quick response time while not necessarily requiring high memory bandwidth, such
as web servers. MemScale minimizes power usage to conform to a predefined
performance level by calculating the system energy ratio---the entire system,
not just the memory subsystems, a key distinction---for all possible
memory frequencies using performance counters largely already existing in
modern systems. As the number of frequency settings is rather small in
memory devices (10 in the study), the overhead of running this brute-force
method for every epoch is negligible. On average, MemScale was able to achieve
system energy savings of 18% with only 4% performance degradation. The authors
close by highlighting the rich possibilities for future research, equating the
active low-power modes to DVFS in its potential to cause dramatic changes in
power consumption for memory systems as DVFS has done for computer systems as a
whole.

In their study, @Diniz:2007:LPC:1273440.1250699 lay out four techniques for
sending memory devices into low power states. The first, dubbed Knapsack, is a
static approach modeled on the well-known Multi-Choice Knapsack Problem, in
which the total power budget is the knapsack's capacity, each memory device and
potential power state is an object with a weight of its power consumption. When
deciding on a memory device and associated power state to enable, the goal is
to pick one object from each set (power state) such that the potential
performance degradation is minimized under the constraint that the overall
power budget is not exceeded, powering down the least recently used device
optimally to stay within the power budget when a new device needs to be powered
up. While the multi-choice knapsack problem is NP-hard, as the number of memory
devices in a system is generally rather low, the computation can simply be
brute-forced ahead of time and the memory controllers initialized with the
mapping information.

The remaining three techniques are fundamentally similar to one another, being
Least-Recently-Used algorithms, though they differ in how they decide which
units to power down and to what level while staying within the power budget.
LRU-Greedy tries to keep as many devices as possible in an active state, and
when needing to release power it places the LRU device in the shallowest
possible state in order to satisfy the budget, continuing to the next LRU
device only if that device is powered off completely and the budget is not
fulfilled. LRU-Smooth behaves similarly, though it instead opts to keep more
devices in shallower states instead of fewer devices in deeper states,
iterating through devices in LRU order and lowering their states one at a time.
The final technique, LRU-Ordered, is a more sophisticated technique that
strives to assign power states evenly while avoiding lowering active devices at
all if possible. Using a priority queue ordered by the shallowness of the power
mode, devices in shallower states are selected to go deeper first. Only if the
queue is exhausted will the system refer to the LRU queue of active devices to
select for powering down. With Knapsack and LRU-Ordered showing the most
promising results, the authors show both significant power savings, as well as
notably energy savings on par or exceeding the savings by the state-of-the-art
performance-aware energy management techniques.

### Reducing capacitance and switching activity

While focusing on the reduction of the voltage and clock frequency
(\(V_{dd}^{2} \cdot f\)) portion of the switching dissipation has yielded
significant results, there remains one other primary pair of variables upon
which careful adjustment can yield further significant power savings:
capacitance and activity factor (\(C \cdot \alpha\)). Fundamentally, the former
is a focus on _how much_ power is used when switching, while the latter is a
focus on _how often_ that switching occurs. Capacitance reduction is a focus on
reducing the overall size of the components and wires that make up the system,
while switching activity is reduced by minimizing the number of times signals
are sent down those wires and through those components.

#### Fundamental design optimizations

At the most fundamental level, significant reductions can be made in power
dissipation by careful design. Data width and number representation can play a
deceivingly large role in power usage, and one must bear in mind the specific
goals for a system when in its design phases [@moyer2001low pp. 1578]. If a
system only requires the manipulation of small, 8-bit numbers, using a 64-bit
design represents an eight-fold power waste for every operation. Using
sign-magnitude number representation can result in significantly less power
usage for some algorithms compared to two's complement [@371964]. Similarly,
reducing the mantissa bit width can yield tremendous energy consumption
improvements in certain applications, up to 66--70% [@tong1998minimizing;
@845894]. Additionally, truncating lower bits when performing certain
arithmetic operations can yield power savings of 30% [@750404]. These
illustrated power savings are a mere sample of what is possible when one
completes a design with the overall goals of the application in mind. While not
applicable in all cases, such as general computing systems, specialized designs
for specialized applications can yield tremendous improvements for power
efficiency [@moyer2001low pp. 1578].

Likewise, careful design of instruction sets is essential for minimizing power
dissipation. Before being executed, each instruction must be fetched, decoded,
and sequenced---unavoidable overhead unrelated to the computation itself.
Instruction design that results in a smaller instruction size and program
footprint can lessen that burden. While simple-but-fast RISC instruction sets
are often preferred for performance reasons, using creative or selectively more
complex instruction sets that either require less space per instruction or
describe more work per instruction can decrease the memory overhead of fetching
the instructions for a program. In addition, using smaller instructions
effectively increases the size of the instruction cache at no cost. As fetching
instructions from the cache is tremendously less expensive than fetching from
memory, large power savings result [@moyer2001low pp. 1582-1583].

Another fundamental area is ensuring optimum layout of components within
circuits. Differing input arrival times to logic components can yield
unnecessary switching if structuring is not optimized;
differences in total transition probabilities of logic gates must be kept in
mind as well, as switching of subsequent logic gates can be avoided without
altering the resulting logical operation. By placing signals with the highest
probability of switching nearest the end of the complex gate and lowest near
the front switches for the component as a whole can be minimized [@moyer2001low
pp. 1579-1580]. However, one must be very careful while reordering in order to
ensure the power savings outweigh any downsides that may result if the new
structure requires more area, as the additional wire length will in turn
increase capacitance.

#### Clock gating

An essential building block of a computer system is the clock pulse. Coursing
throughout the system at a rate of millions of times per second, the energy
consumed by these pulses consumes a large fraction of overall power: upwards of
40% [@moyer2001low pp. 1580]. By gating these clock pulses---cutting them off
from reaching idle units not needed for the particular task at hand---these
signals will be prevented from enabling the activity of the circuits that play
no role in the current computation task. When applied correctly, clock gating
can result in power savings with no performance hit, as these units and
subsystems are by definition not required for the task anyway.

Gating at the unit level is a relatively simple task which is in fact performed
at the register transfer level: when a unit's inputs do not change or outputs
are not required a recomputation does not need to be performed, so the clock
pulse can be cut off without affecting the result [@Kaxiras2008 pp. 52;
@moyer2001low pp. 1580]. These principles can be applied to entire pipeline
stages, disabling stages and their associated subsystems when a given
instruction does not require them---for example, the memory stage and memory
modules can be clock gated when no load or store is being performed [@1183529].

#### Width adjustment

Related to the discussion of bit width above, even when designing systems that
do utilize the full 32 or 64-bit width, this full width is not required all of
the time for every operation. For example, addresses are rarely accessed via
offset addressing using offsets that require more than 16 or 8 (or fewer) bits
[@Hennessy:1992:CAQ:573164], thus the arithmetic units performing the address
calculation are wasting power by considering the entire system's bit-width.
Various techniques exist to detect and react to these smaller-than-maximum
width operands, involving primarily either disabling components that operate on
the unused bits (reducing power directly) or combining multiple narrow-width
operands into the full width supported by the system (improving performance and
energy per operation, and thus Energy Delay Product) [@Kaxiras2008 pp.
60].

These techniques can be applied even further by considering the possibility of
compression, wherein data that does indeed use the full bit-width can be
compressed to a smaller format, allowing for similar power improvements as
less-than-maximum width data.

#### Capacity adjustment

A result of decades of focus on performance improvement, modern processors are
designed to provide a high level of computation through the use of techniques
like instruction windows, out-of-order execution, aggressive caching
techniques, and branch prediction, processors are doing as much work as
possible in order to eek out the maximum performance that they can. However,
many use-cases do not require such extensive performance improvements given
their penalty to energy efficiency. Knowing when to forgo these power-hungry
performance enhancements is essential for preserving energy [@Kaxiras2008 pp.
70-72].

#### Reuse of resources

The underlying concept behind reducing switching activity is avoiding
unnecessary work. While the focus on avoiding such work entirely is crucial, it
is equally beneficial to avoid **redoing** work that has already been done.

Memoization is a technique common in software design, and its principles can be
applied equally well to system design. The concept is simple, if an output
result is dependent solely on its inputs, and those inputs have not changed,
the result must necessarily be the same as it was after its last computation.
By utilizing a mapping structure from inputs to outputs, previous results can
simply be reused instead of being performed again. This concept can be applied
at various levels---for example, arithmetic operations
[@Citron:1998:AMP:384265.291056], entire instructions
[@Sodani:1997:DIR:384286.264200], or even basic blocks
[@Huang:1999:EBB:520549.822778].

#### Cache techniques

In addition to storing and reusing results of operations, optimized caching
techniques along with  specialized forms of caches can be introduced in order
to save from fetching data from the more expensive general cache (or in worst
case the even significantly more expensive main memory).

The filter cache, first introduced by @645809, is a reaction to the large (and
thus power-hungry) on-chip caches that have been introduced into processors in
order to increase performance. While more efficient than main memory, these
caches have grown in size, taking up a significant portion of the size of the
entire chip. The authors insert a very small and energy-efficient cache in
between the processor and its original level-1 cache. The L1 cache can then be
kept in a low-power state until a miss in the filter cache occurs. The authors
show that even a minuscule cache---256 or 512 bytes compared to a 32 KB L1
cache---can provide a hit rate high enough to result in only 21% performance
reduction for its 58% power improvement, resulting in a 51% improvement in
energy-delay product. While the tiny cache does indeed reduce performance, the
power savings can more than make up for it.

@808570 take the concept of the filter cache and augment it with an intelligent
compiler system that searches the source code of the system's software for
the optimal basic blocks to save in the small and efficient filter cache. By
optimizing to cache the instructions that are most deeply nested in loops, and
thus are likely to be executed the most times, a greater proportion of
instructions can be read from the smaller cache.

In attempt to reduce the aforementioned power dissipation caused by instruction
windows in the quest for faster performance, the _trace cache_ introduced by
@566447 takes a slightly different approach from that of the loop cache, and
from traditional instruction caches in general. Typically, instructions are
cached sequentially, in the order they are specified in the source program.
While this makes sense for sequential, straightforward logic, it does not
provide substantial benefits for code that makes use of many branches. To
combat this, the trace cache saves full _traces_ of instructions as they are
executed, rather than as they are written. The next time the same trace is
executed, given that the branches resolve to the same logic path (as they often
do), the instructions are then fetched from the small filter cache-sized trace
cache instead of the main instruction cache.

@Ghose:1999:RPS:313817.313860 utilize three primary techniques for reducing
on-chip cache power dissipation by as much as 75%: subbanking, multiple line
buffers, and bit-line segmentation.

Exploiting the locality of reference in addressing streams, utilizing multiple
line buffers results in the ability to reuse the information already present in
the buffer in cases when the data was recently read. Normal cache access can
thus be avoided by simply reading from the line buffer instead of looking up
the address's tag and fetching it from the cache.

Subbanking, also known as column multiplexing, consists of a number of
consecutive-bit columns of the data array, thus spreading the data line across
a number of subbanks. By reading data from only one subbank at a time instead
of the entire line, switching energy can be avoided in the unneeded subbanks.
Because data is read from only one subbank at a time, a common set of sense
amps can be shared across the entire line, reducing cache area (and thus,
additionally, leakage dissipation).

Finally, bit-line segmentation is achieved by splitting columns of bitcells
sharing one or more pairs of bitlines into independent segments, with one
additional pair of lines running across the newly created segments. While
additional line does increase power usage, this can be mitigated somewhat by
using a metal layer to distribute the clock, because the clock does not need to
be routed across the bit cell array. When fetching data, the address decoder
identifies the target segment and isolates the rest from the common line,
reducing effective capacitance by only loading from the segment that is needed.

### Reducing short-circuit power dissipation

Fortunately, reducing the power wasted via short-circuit power dissipation is
rather straightforward. By optimizing inverters such that the input signal
rise and fall times are as equivalent as possible to their output signal rise
and fall times, the period during which they are both active will be
minimized, resulting in as little as 5--10% of total overall dynamic power
dissipation being due to short circuits [@1052168; @chandrakasan1992low].

## Techniques to reduce leakage

While tremendous savings have been provided by focusing on minimizing dynamic
power consumption, this very fact is leading to reduced opportunity for future
improvements. With modern CPUs equipped with built-in clock gating, optimized
data paths, and a significantly smaller \(V_{dd}\)-to-\(V_{T}\) ratio than in
years past, the low-hanging fruit for dynamic power savings have largely been
picked. This effect is compounded by the vast decreases in feature size, with
current leakage power dissipation approaching dynamic power dissipation and
trending to exceed it at the 65nm feature size [@park2005sleepy pp. xv,1;
@Kaxiras2008 pp. 113].

### Process-level

One of the two types of leakage, gate leakage, has skyrocketed in recent years
as the size of transistors has decreased. While few architectural solution
currently exist to combat the rapid increase, such as the general goal of
reducing supply voltage and temperature, the use of thicker, *high-k*
dielectric materials to insulate the transistors is a promising process-level
solution to prevent electrons from passing through the insulators and wasting
power without sacrificing performance [@Kaxiras2008 pp. 137].

Mobile processor manufacturer Samsung has developed a novel design to minimize
gate leakage through what they call the FinFET design. The design consists of a
three-dimensional fin-shaped structure which allows process nodes to be shrunk
to sizes below 20nm while minimizing gate leakage due to the gate being fully
embedded within the gate oxide, instead of merely sitting below it [@finfet].

### Power Gating

Components cannot leak power to ground if they have no power being sent to them
in the first place. This is the primary concept behind power gating: completely
disconnecting a component from receiving current (or equivalently, from
reaching ground). While the concept is straightforward, applying it effectively
can be complicated, as it results in the loss of state and potentially long
wakeup times. In order to minimize a system's power wasted by leakage, one has
to optimize for being able to completely power down components when idle,
requiring careful planning and optimizing for statelessness.

Phoenix is an architecture for an embedded system proposed by @seok2009phoenix
that makes extensive and clever use of power gating to maximize the lifespan of
embedded sensor systems. While voltage scaling and other dynamic techniques
reduce power consumption during operation, they do not have an effect on the
power consumed during standby. In embedded systems, idle periods can represent
upwards of 99% of the lifetime of a device, and as such, relying on dynamic
techniques alone will have very little effect on lifetime elongation. Because
power gating destroys state, it cannot be applied directly to the system's SRAM
as it is needed to retain data. The authors use a free-list-based leakage
reduction scheme to power gate individual rows within the module; the list
contains information about whether a row is currently in use, and thus any
unused rows and associated peripherals can be safely gated. For instruction
memory, Phoenix makes use of a low-voltage static read-only-memory alongside
the SRAM that can be power gated, resulting in 43% standby savings and 10% area
reduction alongside 26-times performance improvement. Finally, the sensors
themselves are designed to be stateless in order to allow for gating; a
temperature insensitive current source and proportional-to-absolute-temperature
current source are fed into a currentless ring oscillator which converts the
temperature current into frequency, which is then fed to an up-counter which
converts it to digitized output. With CPU standby power improved by 1000 times
via their optimized power gating switch size and their SRAM and ROM power
gating, the authors were able to achieve over 4000--7000 times standby power
improvement over competing research.

MBus is a novel interconnect bus introduced by @pannuto2015mbus. MBus
automatically performs power gating to each component of a system using an
interconnect of two "shoot-through" rings, one for clock and the other for
data. Additionally, the authors introduce the concept of _power oblivious
communication_, in which the components sending data through the bus can do so
with total disregard for the power state of the destination. Communication can
be made as if recipients were always on, and the bus itself handles the burden
of waking them if necessary using an always-on, low power _mediator_ which
resolves arbitration. A power-gated node uses the edges from the clock ring
resulting from that arbitration to wake its bus controller, which then
determines whether the message is destined for the particular node, at which
point the node will be fully waked only upon an address match. Additionally,
the always-on MBus frontend offers an interrupt port that can be asserted by
components. When doing so, MBus will send an empty message to the intended
destination of the interrupt, which is then awoken by its bus controller at
which point it will be able to service the interrupt.

### Drowsy effect

While power gating offers tremendous power savings, its primary drawback is
that it is inherently a *non-state-preserving* technique, as state is lost when
current is cut to a component. This has led to research into techniques which
preserve state while saving as much power as possible. The so-called drowsy
effect is a primary result of such studies.

Effectively equivalent to dynamic voltage scaling for leakage power, the drowsy
technique involves scaling a component's (V\_{dd}) downward to decrease the
differential from its threshold voltage, reducing leakage dissipation. By
maintaining current to the component, state is not lost, however indeed not as
much power is saved compared to cutting it off completely. A "sleeping"
low-(V\_{dd}) component cannot be immediately accessed with full-voltage
lines---it must be scaled back up to full---though the scaling back up can be
completed in a mere few clock cycles, making it much faster than a full
cold-start wake from a power gated device. The relatively low cost of waking
makes the drowsy effect applicable in situations where full power gating is
not, such as memory or caches which are expected to be accessed in the near
future [@Kaxiras2008].

@park2005sleepy illustrates the leakage dissipation that can be saved by
utilizing the drowsy effect. Dubbed the "sleepy stack", the author introduces a
low-leakage technique that can be applied to generic logic circuits, and
applies that technique to present a sleepy stack SRAM cell and pipelined cache.
By combining two previously-researched techniques, the forced stack technique
and the sleep transistor technique, sleepy components are able to utilize
high-threshold voltage transistors---decreasing leakage up to 10 times compared
to the forced stack inverter---while still maintaining state and keeping wakeup
delay low.

## Domain-specific optimizations

In this section we will focus on a few assorted techniques that prove useful in
domain-specific situations, though which did not fit cleanly into a previous
category.

### Web servers

In addition to the web server-focused memory optimizations by
@Meisner:2011:PMO:2024723.2000103 and @6178197,
@Elnozahy:2003:ECP:1251460.1251468 utilize dynamic voltage scaling along with a
new mechanism which they call _request batching_ in order to reduce power
dissipation. Used during low-workload intensity periods, request batching
reduces responsiveness to save energy. While most web servers operate at a
relatively low capacity for the majority of the time, the unpredictability of
incoming requests means energy states with long wakeup times cannot be utilized
in many cases without drastically increasing response times. However, by
queueing incoming requests for a predefined _batching timeout_ period and using
signals similar to the common Wake-On-LAN signal to wake the processor from its
deep sleep state, the wakeup penalty is amortized across the request packet
pool. Combined with DVS when the system is active, the authors report 30--39%
power savings as workload intensity ranges from 1--6 times.

### Embedded sensor systems

Augmenting the techniques used in embedded sensor systems illustrated by
@seok2009phoenix is the dynamic time warping technique shown off by @6513638.
As human gestures of interest are often of relatively long duration and
constrained by the fundamental mechanics of the human body itself, target
gestures can be accurately identified using low-resolution and low-frequency
templates at low power. Building upon the techniques for template-based
filtering using dynamic time warping presented by @5955302, using a
multiple-tier granular decision making module based on the warping technique,
each successive tier processes the sensor readings at an increased frequency
and resolution than the previous tier. When a tier matches an event to the
target gesture within a predefined threshold, the event is forwarded to the
subsequent tier. Only after successfully passing the testing of every tier is
the microcontroller that actually processes the events awoken. Compared to a
low-power microcontroller performing the job of filtering the events itself,
the authors have been able to show a tremendous 99.7% power reduction with only
3% error rate using a 3-tiered granular decision making module.

### High-workload data science computations

While often in order to save power one must sacrifice some performance, that is
not always the case. When a system is performing high-capacity tasks, such
performing as complex data science computations, completing them more quickly
and efficiently saves power as well. @6113792 present a system architecture
customized for data science processing they call PEPSC: a Power-Efficient
Processor for Scientific Computing. While the SIMD nature and high performance
of GPUs has resulted in tremendous performance improvement for data science
computation, they are large, power hungry, require complex cooling mechanisms,
and optimized for processing graphics and not for running at peak capacity
doing nonstop computations. PEPSC utilizes a combination of a two-dimensional
SIMD datapath, a dynamic prefetching mechanism, and configurable SIMD control
in order to increase execution and efficiency. The key feature of the system's
datapath is that its second dimension is utilized for operation chaining
techniques; operations are specified to be performed back-to-back after one
another. Because results pass through the entire chain before being stored,
intermediary data representations can be used throughout the entire series of
operations, saving significant time and hardware that traditionally is used to
normalize and convert the data to IEEE standard representations. PEPSC has been
shown to to use these improvements to provide a tenfold power efficiency
improvement over modern GPUs for data science processing.

# Application

This section contains a brief overview of the low-power processors and
microcontrollers available on the market today.
With a staggering number of processors and chipsets available on the market
today, covering them all would be simply impossible. As such, only a few
particularly low-power-focused highlights from a collection of the top
processor manufacturers are included.

## Arm

While not a manufacturer of the chipsets themselves, Arm Holdings architects
and designs the majority of low-power microprocessors in the current market.
Arm offers five primary lines of architectures and processors with two to
sixteen models per line, which it designs and licenses to manufacturers to be
created and distributed [@arm]:

1.  **Cortex-A:** Their top line, Cortex-A processors are designed for use
    cases where both performance and power-efficiency are of high importance.
	Claiming example use cases of automotive, industrial, medical, modem, and
	storage, the line is led by its flagship Cortex-A76 CPU, a second
	generation premium core built on their DynamicIQ technology. When paired
	with a Cortex-A55 CPU in their big.LITTLE configuration (a heterogenous
	architecture combining a larger, high-performance CPU with a smaller,
	high-efficiency CPU in attempt to maximize both [@bigLITTLE]), the A76
	claims to provide laptop-class performance with mobile efficiency with 40%
	improved power efficiency and 35% performance improvements compared to its
	predecessor, the Cortex-A75. The A76 features an Armv8-A architecture, with
	a 64KB L1 I-Cache and D-Cache,and 256 to 512KB Private L2 cache with ECC,
	with an optional 512KB--4MB L3 Cache all with error-correcting code (ECC)
	support [@cortexa76]. Fifteen other A-models are offered at varying
	performance, power-efficiency, size, and price points.
2.  **Cortex-R:** Designed for real-time processing tasks such as self-driving
	cars, the R series is led by the Cortex-R52. The R52 provides local and
	regional clock gates with automatic controls, architectural clock gating
	for each core, and control mechanisms to support power gating of individual
	cores to reduce static power dissipation [@cortexr52 pp. 192].
3.  **Cortex-M:** The lowest-power and cheapest architecture, the M line is
	designed for ultra-low-power embedded and IoT devices. The lowest power
	processor of the series, the Cortex-M0+, was designed for low operational
	power, ultra low idle power, low interrupt and wakeup latencies, and
	deterministic behavior. With a reduced two-stage pipeline that requires
	fewer flip-flops and reduced branch shadows, the M0+ improves performance
	upon its non-plus M0 predecessor by 9%. Combined with its half-word
	unaligned branch target addressing using 16-bit transfers, separate debug
	power domain, architectural clock gating, 32-bit instruction fetches
	reducing flash memory activity by almost half, and Wakeup Interrupt
	Controller allowing near-instantaneous wakeup using State Retention Power
	Gating, the M0+ boasts a best case 30% power reduction over the M0
	[@cortexm0plus].
4.  **SecurCore:** Arm offers SecurCore processors, the SC300 and SC000,
    designed for security-critical applications such as payment systems and
    authentication services.
5.  **Machine Learning:** Via its Project Trillium, Arm provides several
	machine learning focused solutions such as the Arm ML Processor offering
	over 3 TOP per watt, an object detection processor, and a neural network
	framework.

## Intel

Long-time industry leader for desktop processors, Intel offers an extremely
broad array of series, sub-series, and associated processors for various use
cases. Their two primary energy-focused lines are the Atom, for mobile devices
and energy-efficient servers, and the Quark, for IoT devices. Additionally,
Intel offers some low-power server processors in its Xeon line [@intel].
Within the Atom line is the E series, designed for embedded applications, which
contains the E3800 product family. The family contains processors ranging from
4-core, 4-thread with 2MB L2 Cache, to single-core, single-thread with 512 KB
L2 Cache [@intelEseries]. The family supports power management features such as
ACPI system states S0, S3--5, core states C0--6, package states C0--7, Link
Power Management, thermal throttling, dynamic I/O power reductions, and active
power down of display links [@atomE3800].

Within the Quark series Intel again offers a variety of subfamilies, including
the C, D, and X families. The SE Microcontroller C1000 is an ultra-low power
device that integrates a Quark processor core, sensor subsystem, memory
subsystem with on-die volatile and non-volatile storage, and I/O interfaces
into a single SoC. The SE processor core utilizes a 32MHz clock frequency,
32-bit address bus, x86-compatible instruction set without x87 floating point,
an 8KB L1 instruction cache, and a low latency Tightly Coupled Memory interface
to on-die SRAM. The SoC supports Quark SE system states Active, Sleep, and Off,
processor states C0--C2LP, and sensor subsystem states Sensing Active, Sensing
Wait, and Sensing Standby, along with integrated DFS, dynamic clock gating,
and autonomous state-based and peripheral clock gating [@quarkC1000]. Designed
for even lower power and long battery life applications such as wearable
sensors and RFID tags, the D1000 microcontroller consumes as low as 1.35mW
active power at its lowest performance settings (up to 30.5mW at its highest),
and as little as 0.78mW halt power usage. It offers fine-grained clock
management with a frequency range from 3.3 to 33MHz, glitch-free switching from
crystal to silicon oscillator, low leakage shutdown mode with glitch-free power
on, fast switching frequency octaves of 4, 8, 16, and 32MHz, along with a
discharge curve from 3.6--2.0V and integrated analog-to-digital converters
[@quarkD1000]. Finally, designed for higher performance embedded systems, the
X1000 SoC operates at 400MHz with low power options to run at half or quarter
frequency and offers 32-bit address and data buses, 16KB shared instruction and
data L1 Cache, and a 512KB on-die embedded SRAM, and supports 128MB--2GB of
memory. The system supports ACPI 3.0 power management specifications,
C0--2 processor power states, and S0, S3, and S4/S5 system power states, and
offers dynamic power-down of memory and functional clock gating for its memory
controller [@quarkX1000].

## AMD

Another long-time desktop processor manufacturer returning to notoriety with a
vengeance with their new Ryzen architectures ("Zen" for CPU and "Vega" for
GPU), AMD offers four embedded CPU series, power-efficient graphics processors,
and 11 types of application-specific embedded solutions.

The two newest embedded processor families are the EPYC Embedded 3000 and Ryzen
Embedded V1000, with the former being a power-focused CPU-only solution while
the latter is a more efficient fully integrated CPU and GPU SoC [@amdEmbedded].
The E3000 line contains four models ranging from 4 cores, 4 threads,
2.1--2.9GHz and 35W thermal design power in the 3101, to the 8 cores, 8
threads, 1.5--3.1GHz and 30W TDP in the 3201, and the 8-core, 16-thread,
2.5--3.1GHz at 55W TDP in the 3251 [@epycE3000]. The V1000 line contains four
models as well, ranging from the V1202B with 2 CPU cores, 4 threads,
2.3--3.2GHz and 12--25W TDP to the 4-core, 8-thread 3.35--3.8GHz V1807B at
35--54W TDP [@ryzenV1000].

Their new power efficiency-focused embedded GPUs include the higher-power AMD
Embedded Radeon E9170 series with 14nm FinFET "Polaris" architecture, eight
compute units at 1.2 TFLOPS, 2 or 4GB 64- or 128-bit memory, 1124 or 1219MHz
graphics clock, 1500MHz memory clock, and 35--50W of total board power, and
more energy efficient E6465 series with two compute units at 192 GFLOPS, 2GB
64-bit memory, <20W thermal design power, 600MHz graphics clock, and 800MHz
memory clock [@amdEmbeddedGPU].

## NVIDIA

Historically a GPU-focused company, NVIDIA has recently entered the CPU market
with its low-power Tegra mobile processors and power-aware Jetson
System-on-Modules (SOMs). The Tegra X1 is a mobile processor based on its
Maxwell GPU architecture, supporting double the raw performance and power
efficiency of its predecessor, the K1. Touted as the world's first TeraFLOPS
mobile processor, the X1 SoC combines four high-performance 64-bit A57s with a
shared 2MB L2 cache and a 48KB L1 I-cache and 32KB L1 D-cache each, and
four power-efficient 32-bit A53s with a shared 512KB L2 cache and 32KB caches
for both instructions and data for each core.
Additionally, the SoC contains a 256 core GPU architecture and is built on the TSMC 20nm
process. Compared to Samsung's Exynos 5433, the manufacturer claims 2 times the
power efficiency for the same performance, and 1.4 times the performance at the
same power consumed [@tegra4]. The Jetson TX2 series also offers two CPU
clusters, with the Denver 2 dual-core cluster optimized for higher
single-thread performance and the quad-core Cortex-A57 cluster focused for
lighter-load multi-threaded tasks. The module operates in three primary power
modes: OFF, ON, and SLEEP at various power levels. When ON, the series features
an advanced power management IC, on-system power gating, on-chip clock gating,
DVFS, and low-power DRAM [@jetsontx2].

While unfortunately specification information only seems to be available to
members of the DRIVE Developer Program, NVIDIA also offers a platform designed
for self-driving cars, with the AGX Xavier boasting 30 TOPS of performance at
only 30 watts [@nvidiaDrive].

## Samsung

Primarily a mobile phone manufacturer, Samsung offers high performance with low
power usage with its flagship processor, the Exynos 9 Series 9820. The
manufacturer claims enhanced battery life due to its 8nm Low Power Plus FinFET
design which reduces power consumption by up to 10% compared to the previous
generation's 10nm LPP process, while simultaneously offering a 7-times
performance improvement for AI-related functions. The Exynos 9820 combines a
dual-core fourth-generation custom CPU, dual-core Cortex-A75, and quad-core
Cortex-A55 on a single die, along with an ARM Mali-G76 MP12 GPU. Utilizing an
intelligent task scheduler that selects the processor most well-suited for the
job at hand and disabling the rest, the chip further improves upon its
predecessor (the 9810) by 15% for multi-core performance, 20% for single-core
performance, and 40% for power efficiency [@exynos9820].

Samsung also offers IoT-focused chipsets in its flagship Exynos i S111.
Claiming a more-than-10-year battery life due to its dynamic frequency scaling
Power Saving Mode that allows notification when in an indefinite dormant state
and an extended Discontinuous Reception that allows equipment to sleep without
network check-in for up to 40 minutes, the embedded
network-and-location-focused processor has a 200MHz Cortex-M7-based chipset,
LTE Release 14 NB-IoT modem, an SRAM size of 512KB, and can provide a downlink
speed of up to 127kbps and an uplink speed of up to 158kbps [@exynosis111].

## Qualcomm

While primarily a mobile processor manufacturer with their Snapdragon line,
Qualcomm also offers energy efficient server processors using their single-chip
platform-level system on a chip technology with their Centriq product family
and Armv8-based Falkor CPU.

Their newest flagship mobile platform, the Snapdragon 855 contains the world's
first commercial 5G chipset with its X50 modem. The chipset contains an
octo-core Kryo 485 64-bit 7nm FinFET feature size CPU and an Adreno 640 GPU,
along with a Hexagon 690 DSP and a dedicated Artificial Intelligence Engine.
The manufacturer claims a 45% performance improvement and a 30% energy
efficiency improvement over its predecessor [@snapdragon855].

The world's first 10nm server processor, the Centriq 2400 is a single-chip
solution with a 48-core design optimized for cloud computing. The processor
offers a 64KB L1 instruction cache with a 24KB single-cycle L0 cache, a 32KB L1
data cache, dual-core structure with 512KB shared unified L2 cache with ECC, up
to 60MB distributed unified L3 cache with ECC, an integrated L2 snoop filter.
To minimize gate leakage, Qualcomm additionally makes use of Samsung's FinFET
process technology [@centriq2400]. In a Qualcomm-sponsored report,
@tiriasCentriq2400 shows results of 1.8--2.3 times performance improvement over
the similarly-priced Intel Xeon Gold 5120 processor while maintaining 0.8x
power consumption and 2.4x performance per watt.

# Promising innovative technologies

In no particular order, this section highlights a few of the promising areas of
research related to novel power reduction technologies in computer
architecture. As the industry at large delves deeper into smaller and smaller
CMOS designs, research into alternative methods of computation are essential in
order to further increase performance and decrease power consumption as we
approach the end of the era in which Moore's Law is valid.

@6287063 attempt to tackle the high power usage associated with nanomagnetic
logic (NML) and magnetic tunnel junctions (MTJs) by combining them with
traditional CMOS components in a novel hybrid CMOS-MTJ architecture. Because of
the nature of magnetic fields which are impossible to sharply terminate at
boundaries in order to effectively clock gate, while possible, nanomagnetic
logic requires an extreme amount of power. However, using tilted MTJs
(junctions with their polarization is tilted at a 45-degree angle to its x and
z axes) neighbor coupling, Spin Transfer Torque (STT) clocking and writing, and
tunnel magnetoresistance reading, the authors are able to reduce energy
consumption by over 95% compared to traditional nanomagnetic logic circuits.
Clocking is performed in three phases, in which a positive pulse enables all
cells, followed by a negative pulse which sweeps cells toward 0 until they
reach the saddle point, and finally another positive pulse which then clocks
the cell. Using this STT technique, a total of 40 cells can be clocked
simultaneously in a single clocking zone at lower energy compared to
field-based clocking. Writing is performed at the microAmp current range
possible because of the tilted angle of the junctions. As electrons are sent
along the polarization angle their momentum is transfered to the free layer and
do not effect adjacent cells. Spin transfer-induced precessional magnetization
reversal can switch more rapidly at higher currents, though using more power in
the process. While the \~96.2% power reduction for half adders, full adders, RC
adders, and 8x8 array multipliers compared to previous NML technologies is
impressive, the authors intentionally did not compare their results to a pure
CMOS design due to NML being an emerging field of study while CMOS has had
decades to mature. While this makes sense, the lack of a state-of-the-art
baseline from which to compare their results makes it difficult to tell whether
their solution is truly viable in practice.

@doi:10.1021/acs.nanolett.8b02849 show off metal-based field emission air
channel transistors in their study, using two in-plane symmetric metal
electrodes for source and drain separated by less than 35nm of an air gap and a
bottom metal gate to tune field emission. Because the gap is smaller than the
mean-free path of electrons in air, electrons are able to travel directly
through the gap without scattering. Using this technology, transistors will not
be required to reside in silicon wafers, allowing fully three-dimensional
transistor networks using a substrate instead; with another full dimension at
architects' disposal, the seemingly never-ending goal of making transistors
smaller can rest, instead allowing focus on building vertically in addition to
horizontally. With a claimed theoretical speed in the THz range and its
metal-oxide-semiconductor field effect transistor (MOSFET) technology, future
research is necessary into this field; however such incredible speeds are
surely a long way away from the current state of the technology.

Finally, @beiu2004novel introduces a "novel" (a word peppered liberally
throughout the paper) analog-digital hybrid technology that is more efficient
than traditional purely-digital logic circuits. While efficient, analog logic
currently suffers from two main problems: their wide range of possible states
are more complex than the conceptually simple on-off of digital logic, and
their low voltages and wide ranges offer lower reliability due to reduced
signal-to-noise ratios. However, taking inspiration from multilayered
artificial neural networks, in which each node computes a weighted sum of
inputs, compares the sum to a threshold, and applies an application function,
the author utilizes the same procedure and applies the identity function
(\(f(x) = x\)), which results in a bounding of the result with a very low
precision. In order to combat the noise that accumulates as analog transistors
are chained one after another, an AAA (analog-analog-analog) block is
followed by an ADA (analog-digital-analog) block that converts the signal back
to a clean boolean value before passing it along to more analog blocks. To
solve the reliability problem that can be caused by the low voltages, the
design simply repeats the same operation multiple times and uses boolean layers
to unify the streams in a two-dimensional scheme that appears as follows:

```
	AAA--ADA--AAA--…
		  A
	AAA--ADA--AAA--…
		  A
    AAA--ADA--AAA--…
```

# Acknowledgment

This paper would not have been possible without the invaluable overview of
power efficiency techniques provided by @Kaxiras2008. While cited
directly often, it was additionally an oft-referenced resource with a fantastic
overview of the computer architecture techniques commonly used to improve power
efficiency. A significant amount of overview and background information was
gained from its contents, and it led to a large number of the works referred to
in this report.

\newpage

