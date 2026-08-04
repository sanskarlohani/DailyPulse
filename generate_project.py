import os
import json
import uuid

# Helper to generate unique 24-char hex strings for Xcode
def make_uuid():
    return uuid.uuid4().hex[:24].upper()

def setup_assets(workspace_dir):
    assets_dir = os.path.join(workspace_dir, "Resources", "Assets.xcassets")
    os.makedirs(assets_dir, exist_ok=True)
    
    # Root Contents.json
    contents = {
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    with open(os.path.join(assets_dir, "Contents.json"), "w") as f:
        json.dump(contents, f, indent=2)
        
    # AppIcon folder
    appicon_dir = os.path.join(assets_dir, "AppIcon.appiconset")
    os.makedirs(appicon_dir, exist_ok=True)
    appicon_contents = {
        "images": [
            {
                "filename": "app_logo.jpg",
                "idiom": "universal",
                "platform": "ios",
                "size": "1024x1024"
            }
        ],
        "info": {
            "author": "xcode",
            "version": 1
        }
    }
    with open(os.path.join(appicon_dir, "Contents.json"), "w") as f:
        json.dump(appicon_contents, f, indent=2)
        
    # Standard dynamic color definitions
    colors = {
        "ThemePrimary": {"light": (0.08, 0.49, 0.98), "dark": (0.34, 0.34, 0.84)},
        "ThemeSecondary": {"light": (0.34, 0.34, 0.84), "dark": (0.08, 0.49, 0.98)},
        "ThemeBackground": {"light": (0.98, 0.98, 0.98), "dark": (0.05, 0.05, 0.08)},
        "ThemeCardBg": {"light": (1.0, 1.0, 1.0), "dark": (0.1, 0.1, 0.14)},
        "ThemeText": {"light": (0.05, 0.05, 0.08), "dark": (0.95, 0.95, 0.98)},
        "ThemeSecondaryText": {"light": (0.4, 0.4, 0.45), "dark": (0.6, 0.6, 0.65)},
        "ThemeBorder": {"light": (0.9, 0.9, 0.92), "dark": (0.18, 0.18, 0.22)}
    }
    
    for color_name, variants in colors.items():
        color_dir = os.path.join(assets_dir, f"{color_name}.colorset")
        os.makedirs(color_dir, exist_ok=True)
        
        color_contents = {
            "colors": [
                {
                    "idiom": "universal",
                    "color": {
                        "color-space": "srgb",
                        "components": {
                            "alpha": "1.000",
                            "red": f"{variants['light'][0]:.3f}",
                            "green": f"{variants['light'][1]:.3f}",
                            "blue": f"{variants['light'][2]:.3f}"
                        }
                    }
                },
                {
                    "idiom": "universal",
                    "appearances": [
                        {
                            "appearance": "any",
                            "value": "dark"
                        }
                    ],
                    "color": {
                        "color-space": "srgb",
                        "components": {
                            "alpha": "1.000",
                            "red": f"{variants['dark'][0]:.3f}",
                            "green": f"{variants['dark'][1]:.3f}",
                            "blue": f"{variants['dark'][2]:.3f}"
                        }
                    }
                }
            ],
            "info": {
                "author": "xcode",
                "version": 1
            }
        }
        with open(os.path.join(color_dir, "Contents.json"), "w") as f:
            json.dump(color_contents, f, indent=2)

def generate_xcodeproj(workspace_dir):
    print("Generating Xcode project structure (including Unit Testing target & shared schemes)...")
    setup_assets(workspace_dir)
    
    # 1. Search for core app Swift files
    app_swift_files = []
    src_subdirs = ['App', 'Models', 'Views', 'ViewModels', 'Services', 'Networking', 'Components', 'Extensions', 'Utilities']
    for subdir in src_subdirs:
        subdir_path = os.path.join(workspace_dir, subdir)
        if not os.path.exists(subdir_path):
            continue
        for root, _, files in os.walk(subdir_path):
            for file in files:
                if file.endswith(".swift"):
                    rel_path = os.path.relpath(os.path.join(root, file), workspace_dir)
                    app_swift_files.append(rel_path)
                    
    # 2. Search for test Swift files
    test_swift_files = []
    test_subdir = os.path.join(workspace_dir, "Tests")
    if os.path.exists(test_subdir):
        for root, _, files in os.walk(test_subdir):
            for file in files:
                if file.endswith(".swift"):
                    rel_path = os.path.relpath(os.path.join(root, file), workspace_dir)
                    test_swift_files.append(rel_path)
                    
    assets_path = os.path.join("Resources", "Assets.xcassets")
    
    # 3. Main Project and Target UUIDs
    proj_uuid = "2C88913B2CE004AB001122AA"
    main_group_uuid = "2C88913A2CE004AB001122AA"
    products_group_uuid = "2C8891452CE004AB001122AA"
    
    # App Target definitions
    app_target_uuid = "2C8891462CE004AB001122AA"
    app_sources_phase_uuid = "2C8891412CE004AB001122AA"
    app_frameworks_phase_uuid = "2C8891422CE004AB001122AA"
    app_resources_phase_uuid = "2C8891432CE004AB001122AA"
    app_product_ref_uuid = "2C8891472CE004AB001122AA"
    app_config_list_uuid = "2C88914A2CE004AB001122AA"
    app_config_debug_uuid = "2C88914B2CE004AB001122AA"
    app_config_release_uuid = "2C88914C2CE004AB001122AA"
    
    # Test Target definitions
    test_target_uuid = "2C8891562CE004AB001122BB"
    test_sources_phase_uuid = "2C8891512CE004AB001122BB"
    test_frameworks_phase_uuid = "2C8891522CE004AB001122BB"
    test_resources_phase_uuid = "2C8891532CE004AB001122BB"
    test_product_ref_uuid = "2C8891572CE004AB001122BB"
    test_config_list_uuid = "2C88915A2CE004AB001122BB"
    test_config_debug_uuid = "2C88915B2CE004AB001122BB"
    test_config_release_uuid = "2C88915C2CE004AB001122BB"
    
    # Target Dependency UUIDs
    target_dep_uuid = "2C88915D2CE004AB001122BB"
    container_proxy_uuid = "2C88915E2CE004AB001122BB"
    
    proj_config_list_uuid = "2C88913E2CE004AB001122AA"
    proj_config_debug_uuid = "2C88913F2CE004AB001122AA"
    proj_config_release_uuid = "2C8891402CE004AB001122AA"
    
    # Map files
    file_map = {}
    
    # Core app files
    for path in app_swift_files:
        file_map[path] = {
            "ref": make_uuid(),
            "build": make_uuid(),
            "type": "sourcecode.swift",
            "is_test": False
        }
        
    # Assets catalog
    file_map[assets_path] = {
        "ref": make_uuid(),
        "build": make_uuid(),
        "type": "folder.assetcatalog",
        "is_test": False
    }
    
    # Test files
    for path in test_swift_files:
        file_map[path] = {
            "ref": make_uuid(),
            "build": make_uuid(),
            "type": "sourcecode.swift",
            "is_test": True
        }
    
    # 4. Generate build files and file references
    pbx_build_files = ""
    pbx_file_references = ""
    
    for path, data in file_map.items():
        basename = os.path.basename(path)
        pbx_build_files += f"\t\t{data['build']} /* {basename} in Sources/Resources */ = {{isa = PBXBuildFile; fileRef = {data['ref']} /* {basename} */; }};\n"
        pbx_file_references += f"\t\t{data['ref']} /* {basename} */ = {{isa = PBXFileReference; lastKnownFileType = {data['type']}; path = \"{path}\"; sourceTree = \"<group>\"; }};\n"
        
    # Add products reference files
    pbx_file_references += f"\t\t{app_product_ref_uuid} /* DailyPulse.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = DailyPulse.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
    pbx_file_references += f"\t\t{test_product_ref_uuid} /* DailyPulseTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = DailyPulseTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
    
    # 5. Compile lists
    app_sources_list = ""
    app_resources_list = ""
    test_sources_list = ""
    
    for path, data in file_map.items():
        basename = os.path.basename(path)
        if data["is_test"]:
            test_sources_list += f"\t\t\t\t{data['build']} /* {basename} in Sources */,\n"
        else:
            if path.endswith(".swift"):
                app_sources_list += f"\t\t\t\t{data['build']} /* {basename} in Sources */,\n"
            else:
                app_resources_list += f"\t\t\t\t{data['build']} /* {basename} in Resources */,\n"
                
    # 6. Group hierarchy definition
    subgroups = {}
    for path in file_map.keys():
        parts = path.split(os.sep)
        current_g = main_group_uuid
        for i in range(len(parts) - 1):
            sub_path = os.sep.join(parts[0:i+1])
            if sub_path not in subgroups:
                subgroups[sub_path] = {
                    "uuid": make_uuid(),
                    "name": parts[i],
                    "children": []
                }
            subgroups[sub_path]["children"].append(parts[i+1])
            
    # Format subgroups output
    pbx_groups = ""
    for sub_path, info in subgroups.items():
        children_lines = ""
        for child in sorted(list(set(info["children"]))):
            child_path = os.path.join(sub_path, child)
            if child_path in file_map:
                children_lines += f"\t\t\t\t{file_map[child_path]['ref']} /* {child} */,\n"
            elif child_path in subgroups:
                children_lines += f"\t\t\t\t{subgroups[child_path]['uuid']} /* {child} */,\n"
        
        pbx_groups += f"\t\t{info['uuid']} /* {info['name']} */ = {{\n"
        pbx_groups += "\t\t\tisa = PBXGroup;\n"
        pbx_groups += f"\t\t\tchildren = (\n{children_lines}\t\t\t);\n"
        pbx_groups += f"\t\t\tname = \"{info['name']}\";\n"
        pbx_groups += "\t\t\tsourceTree = \"<group>\";\n"
        pbx_groups += "\t\t};\n"
        
    # Main group references
    main_children = ""
    for sub_path, info in subgroups.items():
        if os.sep not in sub_path: # Top level subgroup
            main_children += f"\t\t\t\t{info['uuid']} /* {info['name']} */,\n"
            
    main_children += f"\t\t\t\t{products_group_uuid} /* Products */,\n"
    
    # Products Group definition
    pbx_groups += f"\t\t{products_group_uuid} /* Products */ = {{\n"
    pbx_groups += "\t\t\tisa = PBXGroup;\n"
    pbx_groups += f"\t\t\tchildren = (\n\t\t\t\t{app_product_ref_uuid} /* DailyPulse.app */,\n\t\t\t\t{test_product_ref_uuid} /* DailyPulseTests.xctest */,\n\t\t\t);\n"
    pbx_groups += "\t\t\tname = Products;\n"
    pbx_groups += "\t\t\tsourceTree = \"<group>\";\n"
    pbx_groups += "\t\t};\n"
    
    # Main Group definition
    pbx_groups_main = f"\t\t{main_group_uuid} = {{\n"
    pbx_groups_main += "\t\t\tisa = PBXGroup;\n"
    pbx_groups_main += f"\t\t\tchildren = (\n{main_children}\t\t\t);\n"
    pbx_groups_main += "\t\t\tsourceTree = \"<group>\";\n"
    pbx_groups_main += "\t\t};\n"
    
    # Construct complete pbxproj text
    pbxproj_content = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile */
{pbx_build_files}/* End PBXBuildFile */

/* Begin PBXContainerItemProxy */
		{container_proxy_uuid} /* PBXContainerItemProxy */ = {{
			isa = PBXContainerItemProxy;
			containerPortal = {proj_uuid} /* Project object */;
			proxyType = 1;
			remoteGlobalIDString = {app_target_uuid};
			remoteInfo = DailyPulse;
		}};
/* End PBXContainerItemProxy */

/* Begin PBXFileReference */
{pbx_file_references}/* End PBXFileReference */

/* Begin PBXFrameworksBuildPhase */
		{app_frameworks_phase_uuid} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{test_frameworks_phase_uuid} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase */

/* Begin PBXGroup */
{pbx_groups_main}
{pbx_groups}/* End PBXGroup */

/* Begin PBXNativeTarget */
		{app_target_uuid} /* DailyPulse */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {app_config_list_uuid} /* Build configuration list for PBXNativeTarget "DailyPulse" */;
			buildPhases = (
				{app_sources_phase_uuid} /* Sources */,
				{app_frameworks_phase_uuid} /* Frameworks */,
				{app_resources_phase_uuid} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = DailyPulse;
			productName = DailyPulse;
			productReference = {app_product_ref_uuid} /* DailyPulse.app */;
			productType = "com.apple.product-type.application";
		}};
		{test_target_uuid} /* DailyPulseTests */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {test_config_list_uuid} /* Build configuration list for PBXNativeTarget "DailyPulseTests" */;
			buildPhases = (
				{test_sources_phase_uuid} /* Sources */,
				{test_frameworks_phase_uuid} /* Frameworks */,
				{test_resources_phase_uuid} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
				{target_dep_uuid} /* PBXTargetDependency */,
			);
			name = DailyPulseTests;
			productName = DailyPulseTests;
			productReference = {test_product_ref_uuid} /* DailyPulseTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		}};
/* End PBXNativeTarget */

/* Begin PBXProject */
		{proj_uuid} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {{
					{app_target_uuid} = {{
						CreatedOnToolsVersion = 15.0;
						DevelopmentTeam = "";
					}};
					{test_target_uuid} = {{
						CreatedOnToolsVersion = 15.0;
						TestTargetID = {app_target_uuid};
					}};
				}};
			}};
			buildConfigurationList = {proj_config_list_uuid} /* Build configuration list for PBXProject "DailyPulse" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {main_group_uuid};
			productRefGroup = {products_group_uuid} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{app_target_uuid} /* DailyPulse */,
				{test_target_uuid} /* DailyPulseTests */,
			);
		}};
/* End PBXProject */

/* Begin PBXResourcesBuildPhase */
		{app_resources_phase_uuid} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{app_resources_list}			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{test_resources_phase_uuid} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase */

/* Begin PBXSourcesBuildPhase */
		{app_sources_phase_uuid} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{app_sources_list}			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{test_sources_phase_uuid} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{test_sources_list}			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase */

/* Begin PBXTargetDependency */
		{target_dep_uuid} /* PBXTargetDependency */ = {{
			isa = PBXTargetDependency;
			target = {app_target_uuid} /* DailyPulse */;
			targetProxy = {container_proxy_uuid} /* PBXContainerItemProxy */;
		}};
/* End PBXTargetDependency */

/* Begin XCBuildConfiguration */
		{proj_config_debug_uuid} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_REPRODUCIBLE_ACTIONS = YES;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUICKLOOK_OBJC_REPLACEMENT = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = NO;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_ACTUAL = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}};
			name = Debug;
		}};
		{proj_config_release_uuid} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_REPRODUCIBLE_ACTIONS = YES;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUICKLOOK_OBJC_REPLACEMENT = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				COPY_PHASE_STRIP = YES;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = NO;
				GCC_C_LANGUAGE_STANDARD = gnu11;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_ACTUAL = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{app_config_debug_uuid} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = ThemePrimary;
				CODE_SIGN_IDENTITY = "Apple Development";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.sanskarlohani.DailyPulse;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{app_config_release_uuid} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = ThemePrimary;
				CODE_SIGN_IDENTITY = "Apple Development";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.sanskarlohani.DailyPulse;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
		{test_config_debug_uuid} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = DailyPulseTests;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.sanskarlohani.DailyPulseTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/DailyPulse.app/DailyPulse";
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{test_config_release_uuid} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = DailyPulseTests;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.sanskarlohani.DailyPulseTests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/DailyPulse.app/DailyPulse";
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration */

/* Begin XCConfigurationList */
		{proj_config_list_uuid} /* Build configuration list for PBXProject "DailyPulse" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{proj_config_debug_uuid} /* Debug */,
				{proj_config_release_uuid} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{app_config_list_uuid} /* Build configuration list for PBXNativeTarget "DailyPulse" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{app_config_debug_uuid} /* Debug */,
				{app_config_release_uuid} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{test_config_list_uuid} /* Build configuration list for PBXNativeTarget "DailyPulseTests" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{test_config_debug_uuid} /* Debug */,
				{test_config_release_uuid} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList */
	}};
	rootObject = {proj_uuid} /* Project object */;
}}
"""

    xcodeproj_dir = os.path.join(workspace_dir, "DailyPulse.xcodeproj")
    os.makedirs(xcodeproj_dir, exist_ok=True)
    with open(os.path.join(xcodeproj_dir, "project.pbxproj"), "w") as f:
        f.write(pbxproj_content)
        
    # Write Workspace structure so it is openable natively
    workspace_path = os.path.join(xcodeproj_dir, "project.xcworkspace")
    os.makedirs(workspace_path, exist_ok=True)
    workspace_data = """<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
"""
    with open(os.path.join(workspace_path, "contents.xcworkspacedata"), "w") as f:
        f.write(workspace_data)
        
    # Generate Shared Scheme XML so CLI xcodebuild test works out-of-the-box
    shared_schemes_dir = os.path.join(xcodeproj_dir, "xcshareddata", "xcschemes")
    os.makedirs(shared_schemes_dir, exist_ok=True)
    
    scheme_xml = f"""<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{app_target_uuid}"
               BuildableName = "DailyPulse.app"
               BlueprintName = "DailyPulse"
               ReferencedContainer = "container:DailyPulse.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldRequestConcretePlatforms = "YES">
      <Testables>
         <TestableReference
            skipped = "NO">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "{test_target_uuid}"
               BuildableName = "DailyPulseTests.xctest"
               BlueprintName = "DailyPulseTests"
               ReferencedContainer = "container:DailyPulse.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_uuid}"
            BuildableName = "DailyPulse.app"
            BlueprintName = "DailyPulse"
            ReferencedContainer = "container:DailyPulse.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "{app_target_uuid}"
            BuildableName = "DailyPulse.app"
            BlueprintName = "DailyPulse"
            ReferencedContainer = "container:DailyPulse.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
"""
    with open(os.path.join(shared_schemes_dir, "DailyPulse.xcscheme"), "w") as f:
        f.write(scheme_xml)
        
    print("Project successfully generated with app and testing targets, plus shared scheme!")

if __name__ == "__main__":
    current_dir = os.path.dirname(os.path.abspath(__file__))
    generate_xcodeproj(current_dir)
