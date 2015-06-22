import FWCore.ParameterSet.Config as cms

process = cms.Process("ANA")

process.load("SimGeneral.HepPDTESSource.pythiapdt_cfi")
process.load("Configuration.StandardSequences.Services_cff")
process.load("GeneratorInterface.HydjetInterface.hydjetDefault_cfi")
process.load('Configuration.StandardSequences.Generator_cff')

process.maxEvents = cms.untracked.PSet(input = cms.untracked.int32(100000)
                                       )

process.source = cms.Source("EmptySource")

#process.load("Configuration.Generator.PythiaUEZ2starSettings_cfi");
# Crashes at event 14xx
process.load("Configuration.Generator.PythiaUESettings_cfi");

process.generator = cms.EDFilter("JewelGeneratorFilter",
                                     frame = cms.string('CMS     '),
                                     targ = cms.string('P       '),
                                     izp = cms.int32(82),
                                     bMin = cms.double(0),
                                     izt = cms.int32(1),
                                     proj = cms.string('A       '),
                                     comEnergy = cms.double(2760.0),
                                     iat = cms.int32(1),
                                     bMax = cms.double(15),
                                     iap = cms.int32(208),
                                     rotateEventPlane = cms.bool(True),
    		                     PythiaParameters = cms.PSet(   
                                        process.pythiaUESettingsBlock,
                                        processParameters = cms.vstring('MSEL=1               ! QCD hight pT processes',
                                                                        'CKIN(3)=80.          ! minimum pt hat for hard interactions', 
                                                                        'CKIN(4)=9990.         ! maximum pt hat for hard interactions'),
                                                                        # This is a vector of ParameterSet names to be read, in this order  
                                        parameterSets = cms.vstring('pythiaUESettings', 
                                        'processParameters')
                                     )
                                 )


process.RandomNumberGeneratorService.generator.initialSeed = 7

process.SimpleMemoryCheck = cms.Service('SimpleMemoryCheck',
                                        ignoreTotal=cms.untracked.int32(0),
                                        oncePerEventMode = cms.untracked.bool(False)
                                        )

process.ana = cms.EDAnalyzer('HydjetAnalyzer'
                             )

process.dijet = cms.EDAnalyzer('DijetNtupleProducer')

process.TFileService = cms.Service('TFileService',
                                   fileName = cms.string('treefileR6.root')
                                   )


process.p1 = cms.Path(process.generator*process.hiGenParticles*process.hiGenJets*process.dijet*process.ana)




