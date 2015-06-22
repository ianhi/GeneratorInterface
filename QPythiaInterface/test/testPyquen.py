import FWCore.ParameterSet.Config as cms

process = cms.Process("ANA")

process.load("SimGeneral.HepPDTESSource.pythiapdt_cfi")
process.load("Configuration.StandardSequences.Services_cff")
process.load("GeneratorInterface.HydjetInterface.hydjetDefault_cfi")
process.load('Configuration.StandardSequences.Generator_cff')

process.maxEvents = cms.untracked.PSet(input = cms.untracked.int32(100000)
                                       )

process.source = cms.Source("EmptySource")

process.load("GeneratorInterface.PyquenInterface.pyquenDefault_cfi")

process.generator.doQuench = True
process.generator.doRadiativeEnLoss = True
process.generator.doCollisionalEnLoss = True
process.generator.qgpInitialTemperature = 1

process.generator.doIsospin = cms.bool(False)
process.generator.comEnergy =cms.double(2760)
process.generator.PythiaParameters.parameterSets = cms.vstring('pythiaUESettings','ppJets','kinematics')
process.generator.PythiaParameters.kinematics = cms.vstring('CKIN(3) = 100','CKIN(4) = 9999')

process.RandomNumberGeneratorService.generator.initialSeed = 5

process.SimpleMemoryCheck = cms.Service('SimpleMemoryCheck',
                                        ignoreTotal=cms.untracked.int32(0),
                                        oncePerEventMode = cms.untracked.bool(False)
                                        )

process.ana = cms.EDAnalyzer('HydjetAnalyzer'
                             )

process.dijet = cms.EDAnalyzer('DijetNtupleProducer')

process.TFileService = cms.Service('TFileService',
                                   fileName = cms.string('Pyquen.root')
                                   )


process.p1 = cms.Path(process.generator*process.hiGenParticles*process.hiGenJets*process.dijet*process.ana)




