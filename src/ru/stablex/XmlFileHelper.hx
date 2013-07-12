package ru.stablex;

import sys.FileSystem;

class XmlFileHelper {

	public static function getPath (__fn:String = ""):String {

		if (!FileSystem.exists (__fn)) {
			return Sys.getEnv("PROJECT_DIR")+'/../../'+__fn;
		}
		else {
			return __fn;
		}

	}

}
