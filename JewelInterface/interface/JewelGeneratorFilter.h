#ifndef gen_JewelGeneratorFilter_h
#define gen_JewelGeneratorFilter_h

#include "GeneratorInterface/JewelInterface/interface/JewelHadronizer.h"
#include "GeneratorInterface/Core/interface/GeneratorFilter.h"
#include "GeneratorInterface/ExternalDecays/interface/ExternalDecayDriver.h"

namespace gen
{
   typedef edm::GeneratorFilter<gen::JewelHadronizer, gen::ExternalDecayDriver> JewelGeneratorFilter;
}

#endif
