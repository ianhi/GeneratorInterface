
// -*- C++ -*-
//
// Package:    DijetNtupleProducer
// Class:      DijetNtupleProducer
// 
/**\class DijetNtupleProducer DijetNtupleProducer.cc CmsHi/DijetNtupleProducer/src/DijetNtupleProducer.cc

   Description: [one line class summary]

   Implementation:
   [Notes on implementation]
*/
//
// Original Author:  Yong Kim,32 4-A08,+41227673039,
//         Created:  Fri Oct 29 12:18:14 CEST 2010
// $Id: DijetNtupleProducer.cc,v 1.2 2011/07/18 15:49:01 kimy Exp $
//
//

// system include files
#include <memory>

// user include files
#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"

#include "FWCore/Framework/interface/EventSetup.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"

#include "TFile.h"
#include "TTree.h"
#include "TH1D.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "CommonTools/UtilAlgos/interface/TFileService.h"
#include "FWCore/Framework/interface/ESHandle.h"

#include "DataFormats/EcalRecHit/interface/EcalRecHitCollections.h"
#include "DataFormats/HcalRecHit/interface/HcalRecHitCollections.h"
#include "CondFormats/DataRecord/interface/EcalChannelStatusRcd.h"
#include "Geometry/Records/interface/CaloGeometryRecord.h"
#include "Geometry/CaloGeometry/interface/CaloGeometry.h"

#include "DataFormats/GeometryVector/interface/GlobalPoint.h"
#include "DataFormats/GeometryVector/interface/GlobalVector.h"
#include "CondFormats/EcalObjects/interface/EcalChannelStatus.h"

#include "DataFormats/CaloRecHit/interface/CaloClusterFwd.h"
#include "RecoEcal/EgammaCoreTools/interface/EcalClusterLazyTools.h"

#include "DataFormats/DetId/interface/DetId.h"
#include "DataFormats/EcalDetId/interface/EcalSubdetector.h"
#include "Geometry/CaloGeometry/interface/CaloSubdetectorGeometry.h"
#include "DataFormats/GeometryVector/interface/GlobalPoint.h"
#include "RecoCaloTools/MetaCollections/interface/CaloRecHitMetaCollectionV.h"
#include "RecoCaloTools/MetaCollections/interface/CaloRecHitMetaCollections.h"
#include <Math/VectorUtil.h>
#include "DataFormats/Math/interface/deltaPhi.h"
#include "DataFormats/EgammaReco/interface/SuperClusterFwd.h"

// #include "DataFormats/HeavyIonEvent/interface/Centrality.h"
// #include "DataFormats/HeavyIonEvent/interface/CentralityProvider.h"

#include "RecoLocalCalo/EcalRecAlgos/interface/EcalSeverityLevelAlgo.h"
#include "TNtuple.h"

#include "SimDataFormats/GeneratorProducts/interface/GenEventInfoProduct.h"
#include "DataFormats/HepMCCandidate/interface/GenParticle.h"
#include "DataFormats/HepMCCandidate/interface/GenParticleFwd.h"
#include "DataFormats/VertexReco/interface/Vertex.h"
#include "DataFormats/VertexReco/interface/VertexFwd.h"
#include "SimDataFormats/Vertex/interface/SimVertex.h"
#include "SimDataFormats/Vertex/interface/SimVertexContainer.h"

#include <memory>
#include <iostream>

// user include files
#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDAnalyzer.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"

#include "FWCore/Utilities/interface/InputTag.h"
#include "DataFormats/HeavyIonEvent/interface/CentralityBins.h"
#include "DataFormats/CaloTowers/interface/CaloTowerCollection.h"
#include "DataFormats/HeavyIonEvent/interface/Centrality.h"
#include "DataFormats/PatCandidates/interface/Jet.h"
#include "SimDataFormats/HiGenData/interface/GenHIEvent.h"
#include "DataFormats/JetReco/interface/CaloJetCollection.h"
#include "DataFormats/JetReco/interface/GenJetCollection.h"

#include "CondFormats/JetMETObjects/interface/FactorizedJetCorrector.h"
#include "JetMETCorrections/Objects/interface/JetCorrectionsRecord.h"
#include "CondFormats/JetMETObjects/interface/JetCorrectionUncertainty.h"

#include "CommonTools/UtilAlgos/interface/TFileService.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "DataFormats/Math/interface/deltaR.h"
#include "FWCore/ParameterSet/interface/FileInPath.h"
#include "FWCore/Framework/interface/ESWatcher.h"

#include "TNtuple.h"
using namespace std;
using namespace edm;

namespace dijet{
  
  static const int MAXJETS = 100;
  
  struct etdr{
    float et;
    float dr;
  };
  struct JRAV{
    int index;
    float jtpt;
    float jtrawpt;
    float refpt;
    float refcorpt;
    float jteta;
    float refeta;
    float jtphi;
    float refphi;
    float l2;
    float l3;
    float area;
    float pu;
    float rho;

  };

  struct JRA{
  public:
    int nref;
    int bin;
    float b;
    float hf;
    float jtpt[MAXJETS];
    float jtrawpt[MAXJETS];
    float refpt[MAXJETS];
    float jteta[MAXJETS];
    float refeta[MAXJETS];
    float jtphi[MAXJETS];
    float refphi[MAXJETS];
    float l2[MAXJETS];
    float l3[MAXJETS];
    float area[MAXJETS];
    float pu[MAXJETS];
    float rho[MAXJETS];

    float weight;
  };

  bool comparePt(JRAV a, JRAV b) {return a.jtpt > b.jtpt;}
}
using namespace dijet;

#define PI 3.14159265

//
// class declaration
//

class DijetNtupleProducer : public edm::EDAnalyzer {
public:
  explicit DijetNtupleProducer(const edm::ParameterSet&);
  ~DijetNtupleProducer();



private:
  virtual void beginJob() ;
  virtual void analyze(const edm::Event&, const edm::EventSetup&);
  virtual void endJob() ;

  // ----------member data ---------------------------

  edm::Service<TFileService> fs;
  
  // CentralityProvider *centrality_;
  TNtuple* nt;
  TTree* t3;
  TTree* t5;
  
  std::string mSrc;
  std::string vertexProducer_;      // vertecies producer                                                                                                                                                       
  float hf;
  int cBin, nPar;
  float recoVtxZ;

  bool doCentrality;

  edm::Handle<reco::JetView> jets;
  edm::InputTag jetTag3_;
  edm::InputTag jetTag5_;
  edm::InputTag eventInfoTag_;

  std::vector<JRAV> jraV;
  JRA current;
};

//
// constants, enums and typedefs
//

//
// static data member definitions
//

//
// constructors and destructor
//
DijetNtupleProducer::DijetNtupleProducer(const edm::ParameterSet& iConfig)
   
{
  mSrc = iConfig.getUntrackedParameter<std::string>("src", "hiGenParticles");
  doCentrality = iConfig.getUntrackedParameter<bool>("doCentrality", true);
  vertexProducer_  = iConfig.getUntrackedParameter<std::string>("VertexProducer","hiSelectedVertex");
  jetTag3_ = iConfig.getUntrackedParameter<edm::InputTag>("src3",edm::InputTag("ak3HiGenJets"));   
  jetTag5_ = iConfig.getUntrackedParameter<edm::InputTag>("src5",edm::InputTag("ak5HiGenJets"));
  eventInfoTag_ = iConfig.getUntrackedParameter<edm::InputTag>("eventInfoTag",edm::InputTag("generator"));
}


DijetNtupleProducer::~DijetNtupleProducer()

{

  // do anything here that needs to be done at desctruction time
  // (e.g. close files, deallocate resources etc.)

}


//
// member functions
//

// ------------ method called to for each event  ------------
void
DijetNtupleProducer::analyze(const edm::Event& iEvent, const edm::EventSetup& iSetup)
{
  using namespace edm;
   
  // Get the primary event vertex                                                                                                                                                                           
  edm::Handle<reco::GenParticleCollection> inputHandle;
  iEvent.getByLabel(InputTag(mSrc),inputHandle);
  //   const reco::GenParticleCollection *collection1 = inputHandle.product();
   
  //   int maxindex = (int)collection1->size();

  nPar = 0 ;

  //   float gammamax = 0, partonmax = 0;

  float pt1 = -9, eta1 = -9, phi1 = -9, dphi = -9,
    pt2 = -9, eta2 = -9, phi2 = -9,
    pt3 = -9, eta3 = -9, phi3 = -9, dphi3 = -9,
    //      pt5 = -9, eta5 = -9, phi5 = -9, dphi5 = -9,
    pt1alt = -9, eta1alt = -9, phi1alt = -9, dphialt = -9,
    pt2alt = -9, eta2alt = -9, phi2alt = -9,
    pt3alt = -9, eta3alt = -9, phi3alt = -9, dphi3alt = -9;

  //   int isFrag = 0;


  //   float parton = -99;

  iEvent.getByLabel(jetTag3_,jets);
  jraV.clear();
   
<<<<<<< HEAD
  current.nref=jets->size();
  //cout <<current.nref<<endl;
  //std::cout<<"before jet loop"<<std::endl;
=======
   current.nref=jets->size();
  // cout<<"nref: "<<current.nref<<endl<<endl;
  //std::cout<<"before jet loop"<<std::endl;
  //commented out 30 June 2015 - Ian Hunt-Isaak
>>>>>>> FETCH_HEAD
  for(unsigned int j = 0 ; j < jets->size(); ++j){
    const reco::Jet& jet = (*jets)[j];
    current.jtpt[j]=jet.pt();
    current.jteta[j]=jet.eta();
    current.jtphi[j]=jet.phi();
 
<<<<<<< HEAD
    float pt = jet.pt();
    //      float phi = jet.phi();
    float eta = jet.eta();

    if(fabs(eta) > 3) continue;

    // change done by Raghav, June1st 2015 
    if(pt < 10) continue;

    JRAV jv;
    jv.jtpt = jet.pt();
    jv.jteta = jet.eta();
    jv.jtphi = jet.phi();
    jv.jtrawpt = jet.pt();
    jv.area = jet.jetArea();
    jv.pu  = jet.pileup();
    jv.index = j;

    jraV.push_back(jv);
  }
  //std::cout<<"before filling the tree"<<std::endl;
  t3->Fill();
  //  std::cout<<"after filling the tree"<<std::endl;
  sort(jraV.begin(),jraV.end(),comparePt);

  if(jraV.size() > 0){
    const reco::Jet& jet = (*jets)[jraV[0].index];
    pt1 = jet.pt();
    eta1 = jet.eta();
    phi1 = jet.phi();
  }

  if(jraV.size() > 1){
    const reco::Jet& jet = (*jets)[jraV[1].index];
    pt2 = jet.pt();
    eta2 = jet.eta();
    phi2 = jet.phi();
    dphi = deltaPhi(phi2,phi1);
  }

  if(jraV.size() > 2){
    const reco::Jet& jet = (*jets)[jraV[2].index];
    pt3 = jet.pt();
    eta3 = jet.eta();
    phi3 = jet.phi();
    dphi3 = deltaPhi(phi3,phi1);
  }

  //cout<<"Done with AK3"<<endl;

  iEvent.getByLabel(jetTag5_,jets);
  jraV.clear();
  current.nref=jets->size();
  for(unsigned int j = 0 ; j < jets->size(); ++j){

    const reco::Jet& jet = (*jets)[j];

    current.jtpt[j]=jet.pt();
    current.jteta[j]=jet.eta();
    current.jtphi[j]=jet.phi();
    //      float pt = jet.pt();
    //      float phi = jet.phi();
    float eta = jet.eta();

    if(fabs(eta) > 3) continue;

    JRAV jv;
    jv.jtpt = jet.pt();
    jv.jteta = jet.eta();
    jv.jtphi = jet.phi();
    jv.jtrawpt = jet.pt();
    jv.area = jet.jetArea();
    jv.pu  = jet.pileup();
    jv.index = j;

    jraV.push_back(jv);
  }
  t5->Fill();
  sort(jraV.begin(),jraV.end(),comparePt);

  if(jraV.size() > 0){
    const reco::Jet& jet = (*jets)[jraV[0].index];
    pt1alt = jet.pt();
    eta1alt = jet.eta();
    phi1alt = jet.phi();
  }

  if(jraV.size() > 1){
    const reco::Jet& jet = (*jets)[jraV[1].index];
    pt2alt = jet.pt();
    eta2alt = jet.eta();
    phi2alt = jet.phi();
    dphialt = deltaPhi(phi2alt,phi1alt);
  }
  if(jraV.size() > 2){
    const reco::Jet& jet = (*jets)[jraV[2].index];
    pt3alt = jet.pt();
    eta3alt = jet.eta();
    phi3alt = jet.phi();
    dphi3alt = deltaPhi(phi3alt,phi1alt);
  }



  edm::Handle<GenEventInfoProduct> hEventInfo;
  iEvent.getByLabel(eventInfoTag_,hEventInfo);
  float pthat = hEventInfo->qScale();

  float entry[]={pt1,eta1,phi1,
		 pt2,eta2,phi2,
		 pt3,eta3,phi3,
		 dphi, dphi3,
		 pt1alt,eta1alt,phi1alt,
		 pt2alt,eta2alt,phi2alt,
		 pt3alt,eta3alt,phi3alt,
		 dphialt, dphi3alt,
		 pthat
  };
=======
      float pt = jet.pt();
//      float phi = jet.phi();
      float eta = jet.eta();

      if(fabs(eta) > 3) continue;

      // change done by Raghav, June1st 2015 
      if(pt < 10) continue;

      JRAV jv;
      jv.jtpt = jet.pt();
      jv.jteta = jet.eta();
      jv.jtphi = jet.phi();
      jv.jtrawpt = jet.pt();
      jv.area = jet.jetArea();
      jv.pu  = jet.pileup();
      jv.index = j;

      jraV.push_back(jv);
   }
  //std::cout<<"before filling the tree"<<std::endl;
  t->Fill();
  //std::cout<<"after filling the tree"<<std::endl;
  //commented out couts 30 June 2015 - Ian Hunt-Isaak
  sort(jraV.begin(),jraV.end(),comparePt);

   if(jraV.size() > 0){
      const reco::Jet& jet = (*jets)[jraV[0].index];
      pt1 = jet.pt();
      eta1 = jet.eta();
      phi1 = jet.phi();
   }

   if(jraV.size() > 1){
      const reco::Jet& jet = (*jets)[jraV[1].index];
      pt2 = jet.pt();
      eta2 = jet.eta();
      phi2 = jet.phi();
      dphi = deltaPhi(phi2,phi1);
   }

   if(jraV.size() > 2){
      const reco::Jet& jet = (*jets)[jraV[2].index];
      pt3 = jet.pt();
      eta3 = jet.eta();
      phi3 = jet.phi();
      dphi3 = deltaPhi(phi3,phi1);
   }

   //   cout<<"Done with AK3"<<endl;

   iEvent.getByLabel(jetTag5_,jets);
   jraV.clear();
   for(unsigned int j = 0 ; j < jets->size(); ++j){
      const reco::Jet& jet = (*jets)[j];
//      float pt = jet.pt();
//      float phi = jet.phi();
      float eta = jet.eta();

      if(fabs(eta) > 3) continue;

      JRAV jv;
      jv.jtpt = jet.pt();
      jv.jteta = jet.eta();
      jv.jtphi = jet.phi();
      jv.jtrawpt = jet.pt();
      jv.area = jet.jetArea();
      jv.pu  = jet.pileup();
      jv.index = j;

      jraV.push_back(jv);
   }
   sort(jraV.begin(),jraV.end(),comparePt);

   if(jraV.size() > 0){
      const reco::Jet& jet = (*jets)[jraV[0].index];
      pt1alt = jet.pt();
      eta1alt = jet.eta();
      phi1alt = jet.phi();
   }

   if(jraV.size() > 1){
      const reco::Jet& jet = (*jets)[jraV[1].index];
      pt2alt = jet.pt();
      eta2alt = jet.eta();
      phi2alt = jet.phi();
      dphialt = deltaPhi(phi2alt,phi1alt);
   }
   if(jraV.size() > 2){
      const reco::Jet& jet = (*jets)[jraV[2].index];
      pt3alt = jet.pt();
      eta3alt = jet.eta();
      phi3alt = jet.phi();
      dphi3alt = deltaPhi(phi3alt,phi1alt);
   }



   edm::Handle<GenEventInfoProduct> hEventInfo;
   iEvent.getByLabel(eventInfoTag_,hEventInfo);
   float pthat = hEventInfo->qScale();
   float entry[]={pt1,eta1,phi1,
		  pt2,eta2,phi2,
		  pt3,eta3,phi3,
		  dphi, dphi3,
		  pt1alt,eta1alt,phi1alt,
                  pt2alt,eta2alt,phi2alt,
                  pt3alt,eta3alt,phi3alt,
                  dphialt, dphi3alt,
		  pthat
   };
>>>>>>> FETCH_HEAD
   
  nt->Fill(entry);

   
}


// ------------ method called once each job just before starting event loop  ------------
void 
DijetNtupleProducer::beginJob() 
{
  
  t3 = fs->make<TTree>("t3","gen jets R=3");
  t3->Branch("nref",&current.nref,"nref/I");
  t3->Branch("jtpt",current.jtpt,"jtpt[nref]/F");
  t3->Branch("jteta",current.jteta,"jteta[nref]/F");
  t3->Branch("jtphi",current.jtphi,"jtphi[nref]/F");
  
  t5 = fs->make<TTree>("t5","gen jets R=5");
  t5->Branch("nref",&current.nref,"nref/I");
  t5->Branch("jtpt",current.jtpt,"jtpt[nref]/F");
  t5->Branch("jteta",current.jteta,"jteta[nref]/F");
  t5->Branch("jtphi",current.jtphi,"jtphi[nref]/F");
  

  nt = fs->make<TNtuple>("nt","","pt1:eta1:phi1:pt2:eta2:phi2:pt3:eta3:phi3:dphi:dphi3:pt1alt:eta1alt:phi1alt:pt2alt:eta2alt:phi2alt:pt3alt:eta3alt:phi3alt:dphialt:dphi3alt:pthat");
   
  // centrality_ = 0;
  std::cout<<"done beginjob"<<std::endl;
}

// ------------ method called once each job just after ending the event loop  ------------
void 
DijetNtupleProducer::endJob() {
}

//define this as a plug-in
DEFINE_FWK_MODULE(DijetNtupleProducer);
