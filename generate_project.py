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
    print("Generating Xcode project structure...")
    setup_assets(workspace_dir)
    
    # Search for all source swift files recursively in designated directories only
    swift_files = []
    src_subdirs = ['App', 'Models', 'Views', 'ViewModels', 'Services', 'Networking', 'Components', 'Extensions', 'Utilities']
    for subdir in src_subdirs:
        subdir_path = os.path.join(workspace_dir, subdir)
        if not os.path.exists(subdir_path):
            continue
        for root, _, files in os.walk(subdir_path):
            for file in files:
                if file.endswith(".swift"):
                    rel_path = os.path.relpath(os.path.join(root, file), workspace_dir)
                    swift_files.append(rel_path)
                
    assets_path = os.path.join("Resources", "Assets.xcassets")
    
    # Generate UUIDs for all elements
    target_uuid = "2C8891462CE004AB001122AA"
    proj_uuid = "2C88913B2CE004AB001122AA"
    sources_phase_uuid = "2C8891412CE004AB001122AA"
    frameworks_phase_uuid = "2C8891422CE004AB001122AA"
    resources_phase_uuid = "2C8891432CE004AB001122AA"
    product_ref_uuid = "2C8891472CE004AB001122AA"
    main_group_uuid = "2C88913A2CE004AB001122AA"
    products_group_uuid = "2C8891452CE004AB001122AA"
    
    proj_config_list_uuid = "2C88913E2CE004AB001122AA"
    proj_config_debug_uuid = "2C88913F2CE004AB001122AA"
    proj_config_release_uuid = "2C8891402CE004AB001122AA"
    
    target_config_list_uuid = "2C88914A2CE004AB001122AA"
    target_config_debug_uuid = "2C88914B2CE004AB001122AA"
    target_config_release_uuid = "2C88914C2CE004AB001122AA"
    
    file_map = {}
    for path in swift_files:
        file_map[path] = {
            "ref": make_uuid(),
            "build": make_uuid(),
            "type": "sourcecode.swift"
        }
    
    # Assets catalog maps to Resources build phase
    file_map[assets_path] = {
        "ref": make_uuid(),
        "build": make_uuid(),
        "type": "folder.assetcatalog"
    }
    
    # Build sections
    pbx_build_files = ""
    pbx_file_references = ""
    
    for path, data in file_map.items():
        basename = os.path.basename(path)
        pbx_build_files += f"\t\t{data['build']} /* {basename} in Sources/Resources */ = {{isa = PBXBuildFile; fileRef = {data['ref']} /* {basename} */; }};\n"
        pbx_file_references += f"\t\t{data['ref']} /* {basename} */ = {{isa = PBXFileReference; lastKnownFileType = {data['type']}; path = \"{path}\"; sourceTree = \"<group>\"; }};\n"
        
    # Standard target product file
    pbx_file_references += f"\t\t{product_ref_uuid} /* DailyPulse.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = DailyPulse.app; sourceTree = BUILT_PRODUCTS_DIR; }};\n"
    
    # Compile sources and Resources build list
    sources_files_list = ""
    resources_files_list = ""
    for path, data in file_map.items():
        basename = os.path.basename(path)
        if path.endswith(".swift"):
            sources_files_list += f"\t\t\t\t{data['build']} /* {basename} in Sources */,\n"
        else:
            resources_files_list += f"\t\t\t\t{data['build']} /* {basename} in Resources */,\n"
            
    # Group hierarchy definition
    # Construct virtual tree of subgroups
    subgroups = {}
    for path in file_map.keys():
        parts = path.split(os.sep)
        # file is at parts[-1], subgroups are parts[0:-1]
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
            
    # Format subgroups for output
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
        
    # Main Group declaration (references high level subgroups)
    main_children = ""
    for sub_path, info in subgroups.items():
        if os.sep not in sub_path: # Top level subgroup
            main_children += f"\t\t\t\t{info['uuid']} /* {info['name']} */,\n"
            
    # Add products group
    main_children += f"\t\t\t\t{products_group_uuid} /* Products */,\n"
    
    # Products Group definition
    pbx_groups += f"\t\t{products_group_uuid} /* Products */ = {{\n"
    pbx_groups += "\t\t\tisa = PBXGroup;\n"
    pbx_groups += f"\t\t\tchildren = (\n\t\t\t\t{product_ref_uuid} /* DailyPulse.app */,\n\t\t\t);\n"
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

/* Begin PBXFileReference */
{pbx_file_references}/* End PBXFileReference */

/* Begin PBXFrameworksBuildPhase */
		{frameworks_phase_uuid} /* Frameworks */ = {{
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
		{target_uuid} /* DailyPulse */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {target_config_list_uuid} /* Build configuration list for PBXNativeTarget "DailyPulse" */;
			buildPhases = (
				{sources_phase_uuid} /* Sources */,
				{frameworks_phase_uuid} /* Frameworks */,
				{resources_phase_uuid} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = DailyPulse;
			productName = DailyPulse;
			productReference = {product_ref_uuid} /* DailyPulse.app */;
			productType = "com.apple.product-type.application";
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
					{target_uuid} = {{
						CreatedOnToolsVersion = 15.0;
						DevelopmentTeam = "";
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
				{target_uuid} /* DailyPulse */,
			);
		}};
/* End PBXProject */

/* Begin PBXResourcesBuildPhase */
		{resources_phase_uuid} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{resources_files_list}			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase */

/* Begin PBXSourcesBuildPhase */
		{sources_phase_uuid} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{sources_files_list}			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase */

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
		{target_config_debug_uuid} /* Debug */ = {{
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
		{target_config_release_uuid} /* Release */ = {{
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
		{target_config_list_uuid} /* Build configuration list for PBXNativeTarget "DailyPulse" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{target_config_debug_uuid} /* Debug */,
				{target_config_release_uuid} /* Release */,
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
        
    print("Project successfully generated!")

if __name__ == "__main__":
    current_dir = os.path.dirname(os.path.abspath(__file__))
    # Assuming files are directly inside the root or DailyPulse folder.
    # The workspace represents /Users/sanskarlohani/personal-projects/DailyPulse.
    generate_xcodeproj(current_dir)
