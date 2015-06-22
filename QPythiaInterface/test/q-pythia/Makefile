all: clean ls main10
        @echo "compile via: make 'ProgramName'"

clean:
	rm -fR *.exe

ls: 
	ls -lh -G --color

#Compile each program
PROGRAM = main10 

main10:
	gfortran -o $@.exe $@.f hirano-nara_3.2.f q-pythia.1.0.3.f

