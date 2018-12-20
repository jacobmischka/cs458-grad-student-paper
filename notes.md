# General links

- https://electronicsforu.com/electronics-projects/electronics-design-guides/low-power-processors-save-power

---

# Technology

> Discuss the underlying technology for low power processor design.

- Power dissipation [@burd1995energy]
- Circuit delay [@burd1995energy]
- Dynamic voltage scaling
- Voltage scheduling
- Ultra low power sleep
- Ultra low voltage (https://en.wikipedia.org/wiki/Ultra-low-voltage_processor)


- @moyer2001low
	- II. Power dissipation:
		- See Section II for power equations
		- 4 primary types of power dissipation
			1. **Switching / dynamic**
			2. Short circuit
			3. Static
			4. **Leakage**


# Computer Organization and Architecture

- Reducing number of transistors overall
- Reducing total length of lines
- Clock gating

- Short circuit
	- @1052168
		- If input and output rise and fall times are equal, time at which
			they're both active will be minimized, resulting in as little as
			5--10% of total dynamic power dissipation

- @moyer2001low
	- III. Design techniques:
		- Algorithmic
			- In general, lowering number of ops is good, though not in all
				cases. For example, recomputing an intermediate result may be
				cheaper than using memory
			- Number representations can play a role.
				- Using signed-mag instead of two's compliment can reduce
					power a lot [20]
				- Precision as well, reducing the mantissa and exponent of
					floating points below the standard can be reduced by up to
					50% with no loss of accuracy [21]. Power savings of 30% mainly
					due to reduced chip area [22]
		- Architectural
			- More parallelism and deeper pipelines can be harmful, as
				incorrect predictions and the additional hardware increases
				power
		- Logic and circuit
			- Restructure logic gates
				- Static logic: To avoid unnecessary switches (Fig 1)
				- Dynamic logic: To reduce overall power costs (Fig 2)
					- May result in increased area, need to weigh tradeoffs
				- Input and transistor reordering for complex operations (Fig 3)
					- Affects amount of switched internal capacitance and
						speed and static power dissipation
					- Inputs with higher prob. of being off are placed nearest
						the end, higher prob of being on at the start, and
						higher prob of switching near the end
					- Average of 10% power savings [29]
				- Clock
					- Clock uses 30-40% of total system power in sync systems
					- Clock gating
					- Reduced swing clock drivers
						- Reducing clock driver supply voltage by 50% and
							providing specially designed flip-flops that
							receive the half-swing clock results in a
							theoretical power saving of 75%, and reported
							saving of 63% in [33]. Though at cost to increased
							flip-flop delay.
						- [34] with increased flip-flop delay by providing
							full Vdd: theoretical 50%, actual 43%
					- Differential clock signalling
					- Utilizing both edges of clock to update registers can
						allow equivalent throughput while cutting clock rate
						in half
						- Dual-edge-triggered flip-flops (DETFF): larger with
							increased loading, but doesn't outweigh the 50%
							reduced clock rate. Detailed comparison in [35].
					- By placing registers at high fanout nodes, the register
						output will transition once per clock cycle at most,
						even if the inputs make multiple transitions
					- Precomputation - precompute the values and then use
						thjem to minimize switching by disabling inputs to the
						logic circuit
						- Increases area, but reduces power overall. Savings
							of 11%-66% in [33]
					- Guarded evaluation [38]: Latches added to inputs and
						disabled when the output can be correctly determined
						without new inputs
		- Device
			- Use smallest devices possible to reduce leakage
			- Lowest overall voltage and frequency possible too obv
		- Instruction set
			- Code density important, because can reduce size of memory and
				results in less data transfer.
				- CISC has advantage here, though its other problems tend to
					counteract that.
				- RISC has disadvantage, with fixed-length instructions
				- Their design reduced memory traffic by 40% (page 8)
				- Smaller instructions effectively increases instruction cache
					size. Accessing the memory itself for instructions is
					significantly more expensive (20x) so large power savings
				- Added `WAIT`, `DOZE`, and `STOP` instructions to power down
					to varying degrees
		- CPU Microarchitecture
			- Many embedded algorithms can't use high parallelism, adding it
				unnecessarily is a waste of space and power
			- Used Focus[39], automatic sizing tool to evaluate tradeoffs
- @burd1995energy
	- ETR = Energy throughput ratio; METR = Microprocessor ETR includes energy
		consumption of idle mode
	- Reduce voltage
	- Vary device width W
	- Scaling clock frequency
	- Burst throughput mode
		- Disabling clock during idle period
	- 4.1 video decompression system
		- Algorithm chosen to be vector quantization
		- Parallel architecture, enabling voltage to be dropped from 5V to
			1.1V, reducing power dissipation by a factor of 20
		- Transistor-level optimizations (??)
	- 4.2
		- Double the hardware, doubling capacatence but maintaining energy per
			operation
		- Reduce voltage to scale throughput down to original value, halving
			clock frequency
	- 4.3: Maximum Throughput Optimization
		- Three levels in IC design hierarchy
			1. Algorithmic level
				- RISC easier to optimize, because closer to machine level.
					CISC has hidden costs requiring more analysis
				- Evaluate instructions to determine if more efficient to
					implement in hardware or software
			2. Architectural level
				- Instruction-Level Parallelism (ILP)
				- Pipelining also increases efficiency, particularly in RISC
					with near 1-cycle per instruction
				- Superscalar architectures
					- Parallel execution units or extended pipelines
				- Speedup S is around 2-3
				- Reduce extraneous switching by gating the clock to various
					parts of the processor when possible
				- Minimize the lengths of the most active busses
			3. Circuit level
				- Low-swing bus drivers (energy per transition drops linearly
					with voltage swing)
				- Reduce every transistor not in critical path to minimum size
					to minimize effective capacitance
	- 4.4
		- "The hardware can enable software power down modes by providing instructions to halt either parts of the processor or the entire thing, as is becoming common in embedded microprocessors."
	- 5
		1. High performance is energy efficient
		2. Clock reduction is not energy efficient on its own
			- Power is halved, but computation time is doubled
- Razor 1[@ernst2003razor] and II [@4735568]
	- Able to scale the voltage and frequency even lower by removing the
		requirement for the worst-case safety margins that ensure correct
		behavior
	- In-situ error dectection and correction
	- Razor 1
		- 76 transistors
		- Delay-error tolerant flip-flop on critical paths to scale the
			voltage to the point of first failure (PoFF)
		- Errors are caught, correct values are propagated using a
			counter-flow pipeline recovery technique
	- Razor 2
		- 47 transistors, or 39 if the detection clock is shared
		- Simplifies 1, using architectural replay instead of the counter-flow
			propagation
		- Means that forward progress isn't _guaranteed_, but by implementing
			a threshold of errors at which frequency is increased this can be
			avoided
		- In practice, most errors simply fix themselves upon second try
			without any voltage adjustment
- @seok2009phoenix
	- Shows how important optimizing for standby power is, especially in
		embedded sensor systems like medical devices
  - Aggressive voltage scaling techniques offers power improvement during operation, though does not address power consumed during standby periods.
  - In embedded sensor systems, standby periods can represent over 99% of a device's lifetime
  - Power gating switch
    - Uses a medium-V_t power gating switch instead of high, because high-V_t cannot meet demand alongside the ultra-low V_dd
    - Very small in order to minimize leakage
  - SRAM cannot be power gated because they need to retain data
    - Uses relatively large (9x) bitcell for IMEM and DMEM, which while leads to higher active energy, not offset by improvement during standby which is most of the time
    - Uses free-list-based leakage reduction scheme
      - Contains info about whether a row is in use, power gating rows 2 at a time during standby mode based on contents of list
      - Peripherals power gated as well
  - Low-voltage static ROM for IMEM that can be power gated
    - Key challenges:
      1. Reduced on-to-off-current ratio can cause robustness issues
      2. potentially large difference between NFET and PFET at low voltages
      3. conventional half-latches likely to lose state
      4. variability
    - Improves performance by 26x, energy by 3.8x, and minimum functional supply voltage by 100mV over dynamic NAND ROM
  - Low power temperature sensor
    - Temp insensitive current source and proportional-to-absolute-temp (PTAT) current source fed into current-starved ring oscillator which translates temp into frequency. clock signals then fed to up-counter to convert to digitized output
    - no state, can be power gated
  - Optimized memory-to-logic area ratio and sweeping tech, size of power gating switch, and supply voltage using Matlab
  - Results
    - CPU standby power improved by 1000x using optimized power gating switch size thus, memory dominates standby power
    - hybrid use of ROM and SRAM for instructions gives 43% standby saving and 10.7% area reduction
    - Hardware compression giving 50% compression ratio
    - Reduces standby power by over 4000-7000x recent competing studies
- @pannuto2015mbus
	- New kind of low-power bus that automatically provides power gating for
		each device, waking it if required and ensuring it gets the data it
		was sent
	- Commonly used pull-up resistors not energy efficient
	- Other energy efficient short-reach data links are monolithic [18, 25]
	- _Wakeup sequence_ outlined in section 3
		- Providing a custom wakeup circuit for each device, as is currently
			done, is expensive and complex
	- MBus design described in section 4
	- Uses arbitration and addressing to wake nodes
		- Nodes are able to send an interrupt to MBus, which prompts a null
			message to be sent to the node itself to wake it
	- Sleep controller, wire controller, and interrupt controller support self
		and system power-gating

## Cache

- @Ghose:1999:RPS:313817.313860
	- Uses subbanking, multiple line buffers, and bit-line segmentation to
		reduce on-chip cache power dissipation by as much as 75%
	- Previous ways of reducing cache power:
		- alternative organizations
		- circuit design techniques applicable to sram components
		- alternative realizations
		- alternative instruction scheduling techniques
	- **Multiple line buffers**:
		- Determine if data is already on the line buffer, if so read it
			directly from there instead of looking up the address's tag first
		- KGM97 Does something kind of similar, using a smaller cache in front
			of the L1 cache. However, decreases performance.
		- This does effectively the same thing, but doesn't decrease
			performance in the case of a line miss
	- **Subbanking**:
		- AKA __column multiplexing__
		- Consists of a number of consecutive bit columns of the data array. A
			data line is thus spread across a number of subbanks; because data
			is read from one subbank at a time, a common set of sense amps can
			be shared across them, reducing cache area and thus leakage
		- Readout of line data from subbanks which might not be needed is
			avoided
	- **Bit-line Segmentation**:
		- Every column of bitcells sharing one (or more) pair of bitlines are
			split into independent segments, with one additional pair of lines
			running across the segments.
			- Metal layer used for clock distribution can be used, because the
				clock does not need to be routed across the bit cell array
		- Address decoder identifies the segmented targeted, and isolates the
			rest from the common line
		- Reduces effective capacitive loading from only loading the segment
			that is needed, though is offset a little by the additional
			hardware required
	- See highlighted figures for results

## Memory

- @6178197
	- Main memory uses 30--40% of the server power according to Google[1]
	- DVFS to the memory controller and DFS to the memory channels and DRAM
		devices
	- Argue that background power is high percentage
	- Lowering frequency affects bandwidth more than latency
		- 800mhz -> 400mhz: -50% bandwidth and +10% latency
		- Affect on power:
			1. Lower background and register/PLL powers linearly
			2. Lowers MC power by cubic factor, similar to CPU DVFS
			3. Increases read/write and termination energy linearly
	- Epoch-based: Selects power-bandwidth points using profiling and
		power/perf models using performance counters:
		1. # Instructions and LLC misses
		2. # of requests outstanding at each bank and channel
		3. Row buffer performance
		4. Time spent in various DRAM states
	- Minimizes power usage to conform to a predefined performance
	- Calculates system energy ratio (SER) for all possible frequencies (only
        10 in study) and just picks the best one
	- Optimizes for full-system energy usage, not just memory
	- 10 freqs * 5ms = negligible overhead
	- Results:
		- 3 workloads: ILP (cpu-bound, highest savings), MEM (memory bound, lowest savings), MID (mix)
		- Max perf degradation 10%
		- Memory energy savings 20--69%
		- System energy savings 8--30%
		- Perf degradation doesn't exceed 7.2%
		- Average:
			- System energy savings: 18%
			- Performance degradation: 4%
	- Combined with Fast Power Down results in max energy saving
	- Key characteristics:
		- _Active low-power modes_: Addresses static energy component, where most
			memory power solutions don't
		- _MC power management_: Servers are using increasingly sophisticated
			MCS with increasing power requirements
		- _Simplicity_: Relies on features primarily already existing (just
			needs that one new perf counter, rest is software)
		- _Effectiveness_: Consistent savings while limiting perf degradation
		- _Rich possibilities for future work_: Much like how DVFS caused
			dramatic changes, active power modes can do the same thing for
			memory
- @Diniz:2007:LPC:1273440.1250699
	- Four techniques:
		1. Knapsack
			- Static approach modeled on the Multi-Choice Knapsack Problem
			- Budget = capacity, each memory device and potential power state
				= object
			- Objects grouped by memory device
			- Weight is its power consumption
			- Goal: pick one object from each set (power state) so that
				potential perf degradation is minimized under constraint that
				power budget not exceeded
			- Computation is performed offline and ahead of time
				- Memory controllers initialized with mapping info
			- MCKP is NP-hard, but given that number of memory devices is
				usually rather low it can just be brute-forced
			- Powers down LRU device optimally to stay within the power
				budget when a new device needs to be powered up
		2. LRU-Greedy
			- Tries to keep as many devices as possible in active state
			- When powering down the LRU device, puts it in the shallowest
				possible state to satisfy the budget. If powered off and still
				not in budget, continue to next LRU
		3. LRU-Smooth
			- Tries to keep more in shallow low-power instead of trying to
				keep fewer in deeper low-power
			- Essentially the same, but iterates through LRU lowering their
				power states one step at a time until in budget
		4. LRU-Ordered
			- Solves problems of previous two: Assign evenly, but avoid
				lowering active devices at all if possible
			- Uses a priority queue ordered by how shallow the power mode is
				- Devices in shallower states are selected to go deeper first
			- LRU queue only contains active devices, rest are just in the
				priority queue (heap)
	- Knapsack and Ordered are the best by far
	- Applying to energy:
		- Send device to lower power state when device has been idle at
			current state for the state's predefined "break-even" time
		- Can stop lowering states based on break even timeouts when going
			below perf degradation budget; can't stop adhering to the power
			budget
		- "More interestingly, in the two IBM p670 servers measured in [21],
			memory power represents 19% and 41% of the total power, whereas the
			processors account for only 24% and 28%"
		- "Limiting power consumption is at least as effective for energy
			conservation as state-of-the-art techniques explicitly designed for
			performance-aware energy management"
		- Optimizing for lower power consumption better in terms of _energy_ than
			the best techniques for reducing _energy_ consumption
			- Optimizing for power optimizes for energy at the same time with no
				additional cost

## Leakage

- @park2005sleepy


- Web servers [@Elnozahy:2003:ECP:1251460.1251468]
	- uses DVS along with __request batching__, a new mechanism
  - Feedback-driven control framework
    - Set percentile response time goal
    - Continuously monitors response times, adjusting policy accordingly
  - DVS
    - Extend recently introduced task-based DVS policies to web server environment
    - Most energy benefits for moderately intense workloads, relatively low benefit for low intensity workloads
  - Request batching
    - Used during low workload intensity
    - Trade off responsiveness to save energy
    - [13] showed that web servers relatively idle most of the time, however because no idea when new requests will come in cannot use energy states with long wakeups
    - Incoming packets are queued in memory until a packet has been pending longer than a predefined __batching timeout__
    - Processor in Deep Sleep in the meantime
    - Wake-On-Lan signals can be reused to wake
    - prototype indicates batching up to 100ms will not adversely affect TCP performance
  - Combining the two, savings between 30--39% as workload intensity varies from 1--6x
- Online data-intensive services [@Meisner:2011:PMO:2024723.2000103]
  - Uses low-power modes while maintaining 95th-percentile latency
  - Server with only 10% load draws 50--60% peak power
  - Full-system idle low-power modes don't work well for OLDI services because they have a large dynamic range (while rarely at max capacity, are essentially never idle)---Need active low-power modes
  - **VFS power savings reduced in future as gap between nominal supply and threshold voltages shrink [6]**
  - Modern CPUs have clock gating built in, power gating modes don't provide much additional benefit

- Dynamic time warping [@6513638]
  - **Need to reference [@5955302] for definition of DTW**
  - Continuous human activity recognition and movement monitoring
  - Goal of harvesting power from body heat (budget of less than 10 microW)
  - Hardware accelerators
  - Removes events that are not of interest as early as possible, allowing remaining modules in pipeline to be deactivated
  - DTW-based granular decision making module (GDMM) which continuously processes sensor readings, only waking microcontroller when gesture of interest is recognized
  - gesture durations long, randomness of data is constrained by human body mechanics so relatively predictable and constrained: targets can be identified using low-res and low-frequency templates at low power
  - Multi-tier, each tier at different res/freq
    - When a gesture is within threshold, move to next tier with finer granularity
  - 99.7% power reduction compared to low-power microcontroller doing all processing/filtering itself, 3% error, 3-tiered GDMM

- PEPSC [@6113792]
  - customized for data science processing, where many power-hungry GPUs are used
  - GPUs designed/optimized for graphics, and not running at peak power doing nonstop math
    - High power usage requiring complex cooling
    - high memory latencies
  - Combination of 2D SIMD datapath, dynamic prefetching mechanism, and configurable SIMD control to increase execution and efficiency
  - 10x efficiency over existing GPUs
  - 2D SIMD datapath
    - number of SIMD lanes first dimension
    - second dimension using operation chaining technique
      - execute back-to-back dependant operations efficiently
      - deeply pipelined fusion of multiple full-function FPUs
        - fewer read-after-write stalls, power saving from fewer access to register file
      - since operations are performed back-to-back, no need to use IEEE representation. can use intermediate arithmetic representationss until the end, saving time and reducing required hardware
      - normalizer typically consumes nearly 30% of computation time, so skipping it saves time and power
  - Dynamic degree prefetcher
    - varies prefetch degree based on application behavior; higher degrees assigned to cyclic code with shorter iteration lengths and vice versa
    - by increasing degree, data is fetched earlier and will be in cache when needed
    - only 0.8% more data, not much power waste
  - SIMD control
    - perf penalty and power waste of executing both sides of a branch, due to SIMD architecture, reduced by effective mapping via PEPSC's chained datapath, executing them simultaneously
  - Since data science requires running at high capacity, increased performance means increased power efficiency
  - over 10x power efficient as modern GPUs

> Discuss computer organization and architecture techniques that lead to low energy and low power processor design

# Application

> Discuss a survey of the contemporary low energy and low power microprocessors and micro-controllers that are commercially available in the market.

- ARM CPUs
	- https://en.wikipedia.org/wiki/ARM_architecture
- http://www.ti.com/general/docs/gencontent.tsp?contentId=46880&DCMP=DSP-LowPowerRoadmap&HQS=Other+BA+dsp-lp-ru

# Critical Thinking

- Highlight importance of sometimes optimizing for performance and then
	sleeping is a better route to low power usage than reducing speed

> Critical thinking, in general, is about quality thinking. Briefly explain the interesting features as well as the shortcoming of the existing work on low power design.

# Creativity

- Magnetic processors (@6287063)
	- Nanomagnetic logic consumes a lot of power, and cannot sharply terminate
		at boundaries in order to clock gate
	- Multilayer Magnetic Tunnel Junctions (MTJs) for logic
		- Can interact through magnetic coupling
	- CMOS-MTJ arch
	- computes using magnetic coupling
	- Writes, clocks, and reads from logic using spin transfer torque (STT)
		current that is more energy efficient
	- Proposed arch achieves >95% energy reduction in adders and
		multipliers compared to traditional nanomagnetic logic
	- Uses tilted MTJs:
		- neighbor coupling
		- Spin Transfer Torque (STT) clocking and writing
			- Clocking
				- Three phases:
					1. Positive pulse, all cells are 1
					2. Negative pulse, cells are swept toward 0 until saddle
					   point
					3. Positive pulse, cell is clocked during pulse
			- Writing
				- microAmp current range (0.8MA/cm^2 current density possible)
				- Possible because it has 45-degree polarized fixed layer in the
					x-z plane
				- Two steps:
					1. Enable word line
					2. Apply positive or negative potential
				- Electrons are sent up at an angle and transfer their momentum to
					the free layer
				- Cell-specific, doesn't affect adjacent cells
				- Spin transfer induced precessional magnetization reversal is
					faster, more current means faster switching (though more power)
				- Equations in table IV
		- Tunnel magnetoresistance (TMR) reading
			- Complex read circuit (Fig 9)
			- Comparator senses voltage difference between two nodes and sets
				its output accordingly
	- Energy comparison in Table VIII
		- Compared to straight-up NML 96.2% reduction for half adder, full adder, RC adder, and 8x8
	- Estimated that with STT current, a total of 40 cells can be clocked
	simultaneously in a single clocking zone at lower energy compared to
	field-based clocking
			array multiplier
- Metal-Air transistors [@doi:10.1021/acs.nanolett.8b02849]
	- https://spectrum.ieee.org/nanoclast/semiconductors/devices/new-metalair-transistor-replaces-semiconductors
	- Metal-based field emission air channel transistor
	- Uses two in-plane symmetric metal electrodes (source and drain)
		separated by less than 35nm air gap and bottom metal gate to tune
		field emission
	- Gap is less than the mean-free path of electrons in air, so they travel
		through without scattering
	- Don't need to sit in silicon, allowing fully 3D transistor networks
		using substrate
	- Can stop worrying about making transistors smaller, and instead just
		build vertically
	- Theoretical speed of ACT in thz range
	- MOSFET
- Vaccuum tube transistors
	(https://spectrum.ieee.org/semiconductors/devices/introducing-the-vacuum-transistor-a-device-made-of-nothing)
- Intel's new 3D stacked processor
	(https://newsroom.intel.com/articles/new-intel-architectures-technologies-target-expanded-market-opportunities/#gs.sTmQ_o0)
	- Dubbed Foveros, logic-on-logic
	- 3D stacking done in high-end memory already, but not in consumer CPUs
	- 10nm chiplet stacked onto low power die
		-
		https://newsroom.intel.com/wp-content/uploads/sites/11/2018/12/3d-packaging-a-catalyst-for-product-innovation.jpg
		- Radio, high-density memory, high-speed Memory, and high-perf logic
			stacked on top of Low power logic
		- Photonics stacked on top of Power regulator
- Analog circuits [@beiu2004novel]
	- Logic can be performed in 3 ways:
		1. Digital (boolean gates)
		2. analog (analog circuits)
		3. mixed
	- mixed expected to be more power efficient
	- analog suffers from problems:
		- more complex
		- lower reliability (signal/noise)
	- multilayered Artificial Neural Networks
		- each node computes weighted sum of inputs, compared to a threshold,
		applied to application function
		- if use the identity function \(f(x) = x\) for application function,
		function is bounded but precision can be very low
		- Concept is simple, use an A-A-A analog block followed by an ADA block
		to resolve the noise accumulation problem that builds up
		- to solve reliability problem, simply do the same thing multple times
		and use the boolean layers to unify the streams
		- Scheme:
			```
				AAA--ADA--…
					  A
				AAA--ADA--…
					  A
				AAA--ADA--…

			```

> Creativity is about finding creative solutions for the existing problems. You may suggest how the current work can be improved (incremental problem solving) or suggest totally new ways to solve the problem (disruptive problem solving).
>
> Focus on new technology and/or new computer organization and architecture that seem promising to pursue? Can you think of new applications for these types of processors?
>
> Be creative. Think out of the box. Free your mind free traditional ways of doing things.
