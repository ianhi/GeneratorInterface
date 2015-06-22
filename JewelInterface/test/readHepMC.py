import FWCore.ParameterSet.Config as cms
process = cms.Process('GEN')

# import of standard configurations
process.load('Configuration.StandardSequences.Services_cff')
process.load('SimGeneral.HepPDTESSource.pythiapdt_cfi')
process.load('FWCore.MessageService.MessageLogger_cfi')
process.load('Configuration.EventContent.EventContent_cff')
process.load('SimGeneral.MixingModule.mixNoPU_cfi')
process.load('Configuration.StandardSequences.GeometryRecoDB_cff')
process.load('Configuration.StandardSequences.MagneticField_38T_cff')
process.load('Configuration.StandardSequences.Generator_cff')
process.load('IOMC.EventVertexGenerators.VtxSmearedRealistic8TeVCollision_cfi')
process.load('GeneratorInterface.Core.genFilterSummary_cff')
process.load('Configuration.StandardSequences.EndOfProcess_cff')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.maxEvents = cms.untracked.PSet(
    input = cms.untracked.int32(10000)
    )
    
# Input source
#process.source = cms.Source("EmptySource")
process.source = cms.Source("MCFileSource",
    fileNames = cms.untracked.vstring("file:out.hepmc")
    )

process.RECOSIMoutput = cms.OutputModule("PoolOutputModule",
    splitLevel = cms.untracked.int32(0),
    eventAutoFlushCompressedSize = cms.untracked.int32(5242880),
    outputCommands = process.RECOSIMEventContent.outputCommands,
    fileName = cms.untracked.string('test.root'),
    dataset = cms.untracked.PSet(
        filterName = cms.untracked.string(''),
        dataTier = cms.untracked.string('')
    ),
#    SelectEvents = cms.untracked.PSet(
#        SelectEvents = cms.vstring('generation_step')
#    )
)
from Configuration.AlCa.GlobalTag import GlobalTag
process.GlobalTag = GlobalTag(process.GlobalTag, 'START53_V7G::All', '')


process.TFileService = cms.Service('TFileService',
                                   fileName = cms.string('treefile.root')
                                                                      )
                                                                      

process.ana = cms.EDAnalyzer('HydjetAnalyzer',
                             src=cms.untracked.InputTag("source")
                             )

process.ana_step = cms.Path(process.ana)                             
process.out = cms.EndPath(process.RECOSIMoutput)

process.schedule = cms.Schedule(process.ana_step,process.out)
