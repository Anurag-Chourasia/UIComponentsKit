"""Generate a disposable native UI-test harness from versioned sources."""
import plistlib,sys,shutil
from pathlib import Path
from xml.sax.saxutils import escape
package=Path(__file__).resolve().parents[1]
root=Path(sys.argv[1]).resolve();root.mkdir(parents=True,exist_ok=True)
project=root/'Interaction.xcodeproj';project.mkdir(exist_ok=True)
objects={};n=0
def obj(isa,**kw):
 global n;n+=1;i=f'{n:024X}';objects[i]=dict(isa=isa,**kw);return i
appfile=obj('PBXFileReference',lastKnownFileType='sourcecode.swift',path='InteractionApp.swift',sourceTree='<group>')
testfile=obj('PBXFileReference',lastKnownFileType='sourcecode.swift',path='InteractionTests.swift',sourceTree='<group>')
appProduct=obj('PBXFileReference',explicitFileType='wrapper.application',path='Interaction.app',sourceTree='BUILT_PRODUCTS_DIR')
testProduct=obj('PBXFileReference',explicitFileType='wrapper.cfbundle',path='InteractionTests.xctest',sourceTree='BUILT_PRODUCTS_DIR')
products=obj('PBXGroup',children=[appProduct,testProduct],name='Products',sourceTree='<group>')
group=obj('PBXGroup',children=[appfile,testfile,products],sourceTree='<group>')
ref=obj('XCLocalSwiftPackageReference',relativePath=str(package))
tokenref=obj('XCRemoteSwiftPackageReference',repositoryURL='https://github.com/Anurag-Chourasia/DesignTokensKit.git',requirement=dict(kind='exactVersion',version='1.0.0'))
deps=[obj('XCSwiftPackageProductDependency',productName=name,package=r) for name,r in [('UIComponentsKit',ref),('DesignTokensKit',tokenref)]]
def configs(bundle,testing=False):
 configs=[]
 for name in ['Debug','Release']:
  settings=dict(PRODUCT_BUNDLE_IDENTIFIER=bundle,PRODUCT_NAME='$(TARGET_NAME)',GENERATE_INFOPLIST_FILE='YES',SDKROOT='iphoneos',IPHONEOS_DEPLOYMENT_TARGET='17.0',SWIFT_VERSION='5.0',TARGETED_DEVICE_FAMILY='1,2',CODE_SIGNING_ALLOWED='NO',SWIFT_OPTIMIZATION_LEVEL='-Onone' if name=='Debug' else '-O',ENABLE_TESTABILITY='YES',ONLY_ACTIVE_ARCH='YES')
  if testing:settings['TEST_TARGET_NAME']='Interaction'
  else:settings['INFOPLIST_KEY_UILaunchScreen_Generation']='YES'
  configs.append(obj('XCBuildConfiguration',name=name,buildSettings=settings))
 return obj('XCConfigurationList',buildConfigurations=configs,defaultConfigurationIsVisible=0,defaultConfigurationName='Debug')
def phase(isa,files=[]):return obj(isa,buildActionMask=2147483647,files=files,runOnlyForDeploymentPostprocessing=0)
app=obj('PBXNativeTarget',name='Interaction',productName='Interaction',productReference=appProduct,productType='com.apple.product-type.application',buildConfigurationList=configs('com.anurag.kits.interaction'),buildPhases=[phase('PBXSourcesBuildPhase',[obj('PBXBuildFile',fileRef=appfile)]),phase('PBXFrameworksBuildPhase',[obj('PBXBuildFile',productRef=d) for d in deps]),phase('PBXResourcesBuildPhase')],buildRules=[],dependencies=[],packageProductDependencies=deps)
proj=obj('PBXProject',attributes=dict(LastUpgradeCheck='2700'),buildConfigurationList=configs('com.anurag.kits'),compatibilityVersion='Xcode 14.0',developmentRegion='en',hasScannedForEncodings=0,knownRegions=['en','Base'],mainGroup=group,productRefGroup=products,projectDirPath='',projectRoot='',targets=[app],packageReferences=[ref,tokenref])
proxy=obj('PBXContainerItemProxy',containerPortal=proj,proxyType=1,remoteGlobalIDString=app,remoteInfo='Interaction')
test=obj('PBXNativeTarget',name='InteractionTests',productName='InteractionTests',productReference=testProduct,productType='com.apple.product-type.bundle.ui-testing',buildConfigurationList=configs('com.anurag.kits.interaction.tests',True),buildPhases=[phase('PBXSourcesBuildPhase',[obj('PBXBuildFile',fileRef=testfile)]),phase('PBXFrameworksBuildPhase'),phase('PBXResourcesBuildPhase')],buildRules=[],dependencies=[obj('PBXTargetDependency',target=app,targetProxy=proxy)])
objects[proj]['targets'].append(test)
with (project/'project.pbxproj').open('wb') as f:plistlib.dump(dict(archiveVersion='1',objectVersion='56',classes={},objects=objects,rootObject=proj),f)
for name in ['InteractionApp.swift','InteractionTests.swift']:shutil.copy2(package/'Validation'/name,root/name)
schemes=project/'xcshareddata/xcschemes';schemes.mkdir(parents=True,exist_ok=True)
def buildref(id,name,ext):return f'<BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{id}" BuildableName="{name}.{ext}" BlueprintName="{name}" ReferencedContainer="container:Interaction.xcodeproj"/>'
(schemes/'Interaction.xcscheme').write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme version="1.7"><BuildAction buildImplicitDependencies="YES"><BuildActionEntries><BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">{buildref(app,'Interaction','app')}</BuildActionEntry></BuildActionEntries></BuildAction><TestAction buildConfiguration="Debug"><Testables><TestableReference skipped="NO">{buildref(test,'InteractionTests','xctest')}</TestableReference></Testables></TestAction><LaunchAction buildConfiguration="Debug"><BuildableProductRunnable>{buildref(app,'Interaction','app')}</BuildableProductRunnable></LaunchAction></Scheme>''')
print(project)
