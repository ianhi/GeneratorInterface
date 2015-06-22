q-PYTHIA from Liliana Apolinario, Carlos Salgado and Nestor Armesto
========

Please find in the attachment a .tar.gz file containing the code of qpythia prepared to perform quenching with a hydro profile. Files are:

- main10.f: the main program. Note that it contains a ptmin for PYTHIA hard event generation of 10 GeV. The program is commented and anyone with some expertise in PYTHIA6 should be able to manage it.

- q-pythia.1.0.3.f: the q-pythia program that must be compiled with the main program (already in Makefile).

- hirano-nara_3.2.f: the program that provides the hydro profile.

- parevo.txt: a table with the corresponding impact parameter for each centrality class. Note that each centrality class implies a different impact parameter, 2.0 fm for the 0-5% one.

- Makefile: contains already the instruction to compile (you only need to type make).

- input: the file that contains the input parameters to be given to main. All the parameters are accompanied by comments, so it should be easy to change them. The value of the impact parameter changes with centrality (see table in parevo.txt).

- grid-qp.dat: an auxiliar file, that must be in the same directory as the executable.

- PbPb2760_00-05.dat: the hydro profile for the centrality class 0-5%. It is not included in this tar.gz file since it has a large size (85 MB when compressed, 0.5 GB decompressed). It must be decompressed in the same directory as the executable. You can download this file from http://www-fp.usc.es/nestor/PbPb2760_00-05.dat.gz. More centrality classes may be made available upon request.

To compile type 'make', and then to run it, type './main10.exe input output', where output is an arbitrary name that will contain the full event display. It is organized as follows: the first line has the total number of events, the second line, the event number with the corresponding number of particles, and from there, the list of particles with the following information: particle_id, px, py, pz, energy, mass (all in GeV). The z axis is the longitudinal and the (x,y) the transverse coordinates, as usual. The form of output can be changed in main10.f.

If you have any question, please don't hesitate to contact us.

Best regards,
Liliana and Nestor


========
In the meanwhile: in the paper, we used a 1 GeV cut for the input particles and the PQM model with the following parameters for <$\hat{q}$>:

0 (0)
14000 (1)
28000 (2)
56000 (4)
112000 (8)