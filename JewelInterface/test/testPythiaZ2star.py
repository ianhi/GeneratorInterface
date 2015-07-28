import FWCore.ParameterSet.Config as cms
import FWCore.ParameterSet.VarParsing as VarParsing
import datetime

process = cms.Process("ANA")

options = VarParsing.VarParsing ('standard')
now = datetime.datetime.now()
options.output = 'PYTHIA_DEFAULT_'+now.strftime("%Y-%m-%d_%H-%M")+'.root'
options.maxEvents = 2000

options.register('ptHatLow',120,VarParsing.VarParsing.multiplicity.singleton,VarParsing.VarParsing.varType.int,"Minimum pt-hat")
options.register('ptHatHigh',160,VarParsing.VarParsing.multiplicity.singleton,VarParsing.VarParsing.varType.int,"Maximum pt-hat")

options.parseArguments()


process.load("SimGeneral.HepPDTESSource.pythiapdt_cfi")
process.load("Configuration.StandardSequences.Services_cff")
process.load("GeneratorInterface.HydjetInterface.hydjetDefault_cfi")
process.load('Configuration.StandardSequences.Generator_cff')

process.maxEvents = cms.untracked.PSet(input = cms.untracked.int32(options.maxEvents)
                                       )

process.source = cms.Source("EmptySource")

process.load("Configuration.Generator.PythiaUEZ2starSettings_cfi");
process.generator = cms.EDFilter("Pythia6GeneratorFilter",
    pythiaHepMCVerbosity = cms.untracked.bool(False),
    maxEventsToPrint = cms.untracked.int32(0),
    pythiaPylistVerbosity = cms.untracked.int32(0),
    filterEfficiency = cms.untracked.double(1.0),
    comEnergy = cms.double(2760.0),
    PythiaParameters = cms.PSet(
        process.pythiaUESettingsBlock,
        processParameters = cms.vstring('MSEL=1          ! QCD hight pT processes', 
                                        'CKIN(3)='+str(options.ptHatLow), 
                                        'CKIN(4)='+str(options.ptHatHigh)
                                ),
        # This is a vector of ParameterSet names to be read, in this order
        parameterSets = cms.vstring('pythiaUESettings', 
            'processParameters')
    )
)


process.RandomNumberGeneratorService.generator.initialSeed = now.microsecond

process.SimpleMemoryCheck = cms.Service('SimpleMemoryCheck',
                                        ignoreTotal=cms.untracked.int32(0),
                                        oncePerEventMode = cms.untracked.bool(False)
                                        )

process.ana = cms.EDAnalyzer('HydjetAnalyzer'
                             )

process.dijet = cms.EDAnalyzer('DijetNtupleProducer')

process.TFileService = cms.Service('TFileService',
                                   fileName = cms.string(options.output)
                                   )


process.p1 = cms.Path(process.generator*process.hiGenParticles*process.hiGenJets*process.dijet*process.ana)




