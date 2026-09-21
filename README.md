# IIT Delhi — Communication Assignments

**Author:** Limnesh Augustine  
**Area:** Wireless communications, quantum communication, and information theory  
**Purpose:** A navigable index of assignment portfolios, study notes, and any associated simulation code.

## Overview

This folder brings together two IIT Delhi study portfolios:

| Portfolio | Focus | Contents |
| --- | --- | --- |
| [Batch 1 — Wireless and Quantum Communication](Batch1.htm) | Digital and wireless communication simulations, plus introductory quantum concepts | 10 assignment sections and an appendix of referenced source files |
| [Batch 2 — Quantum Communication](Batch2.htm) | Quantum foundations, information theory, cryptography, and networking | 7 assignment sections, a reflection, and a formula appendix |

The HTML files are the **portfolio documents**. They describe simulations and study topics; they are not themselves runnable notebooks or MATLAB scripts. Source filenames listed below are referenced in the portfolios, but their presence in this folder has not been verified.

## Batch 1: Wireless and Quantum Communication

**Portfolio:** [`Batch1.htm`](Batch1.htm)

| # | Assignment | Main focus | Referenced source file(s) |
| --- | --- | --- | --- |
| 1 | BER Analysis of BPSK, QPSK, and 16-QAM over AWGN | Simulated versus theoretical BER, constellation diagrams, and modulation trade-offs | `Assignment1_JupiterNotebook.ipynb` |
| 2 | Quantum Communication Fundamentals and Bloch Sphere Visualization | Qubit initialization and Bloch sphere visualization using Qiskit | `Assignment1_JupiterNotebook.ipynb` (Part B) |
| 3 | Rayleigh Fading and BER Analysis | Rayleigh channel statistics and error performance | `BER.ipynb` |
| 4 | OFDM Simulation and Frequency-Selective Channel Equalization | 64-subcarrier OFDM, cyclic prefix, multipath, and zero-forcing equalization | `OFDM_Simulation.m` |
| 5 | Path Loss Modeling and Wireless Coverage Analysis | Free-space/environmental path loss, shadowing, and coverage mapping | `PathLossModeling.m` |
| 6 | Pilot-Assisted OFDM Channel Estimation | Pilot insertion, least-squares channel estimation, interpolation, and equalization | `ChannelEstimationPilot.m` |
| 7 | Diversity Techniques: SC, EGC, and MRC | Diversity combining and Monte Carlo BER comparison | `Diversity_SC_EGC_MRC.m` |
| 8 | Monte Carlo Outage Probability Simulation | Rayleigh fading outage simulation versus its theoretical expression | `MonteCarlo_OutageSimulation.m` |
| 9 | Modulation Lab: BPSK, QPSK, and 16-QAM | Modulation waveforms, AWGN effects, and constellation plots | `modulation_lab.m`, `modulation_lab_visual.m` |
| 10 | Comprehensive Study Summary and Reflection | Summary of wireless and quantum communication concepts covered | No separate source specified |

The Batch 1 appendix additionally names `Rayleigh_Rician.m`, without assigning it to a specific numbered section.

## Batch 2: Quantum Communication and Information Theory

**Portfolio:** [`Batch2.htm`](Batch2.htm)

| # | Assignment | Main focus |
| --- | --- | --- |
| 1 | Quantum Foundations and Qubits | State vectors, superposition, Hilbert spaces, Bloch sphere, and the Born rule |
| 2 | Measurement, Operators, and Density Matrices | Pauli operators, observables, pure/mixed states, and density matrices |
| 3 | Entanglement and Bell States | Bell states, quantum correlations, Bell inequalities, and entanglement applications |
| 4 | Quantum Key Distribution (QKD) | BB84, E91, eavesdropping detection, and quantum bit error rate (QBER) |
| 5 | Quantum Channels and Decoherence | Noise models, Kraus operators, coherence, and fidelity |
| 6 | Quantum Teleportation and Repeaters | Bell-state measurement, classical communication, entanglement swapping, and repeaters |
| 7 | Advanced Study and Applications | Satellite quantum communication, quantum networks, photonics, quantum memory, and research directions |

Batch 2 also contains a **Reflection and Summary** and **Appendix A: Core Quantum Communication Formulae**.

## Opening and running the work

1. Open `Batch1.htm` or `Batch2.htm` in a web browser to read the portfolios. Microsoft Word can also open these Word-exported HTML documents.
2. If the referenced `.ipynb` files are included, open them in Jupyter Notebook or JupyterLab. The Bloch sphere section references **Qiskit**.
3. If the referenced `.m` files are included, open them in **MATLAB**. Check individual scripts for toolbox requirements and compatibility before running.
4. Compare generated figures and numerical results with the explanations in the appropriate portfolio.

> **Dependencies:** No executable source files, package manifest, MATLAB release, or tested environment was supplied with the two HTML documents. This README therefore does not claim that every referenced simulation is present or executable as-is.

## Repository notes

- Keep the original assignment documents and simulation sources together so the source filenames remain easy to locate.
- Add the `.ipynb` and `.m` files when available; update this README if filenames or folder structure change.
- Record submission status, grades, and deadlines separately: neither portfolio establishes those details.
- Review any institutional or workplace confidentiality markings before publishing this folder publicly.

---

*Index prepared from the supplied `Batch1.htm` and `Batch2.htm` portfolios.*
