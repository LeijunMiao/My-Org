function popRemove() {
	$("#email_template_window").remove();
	$("#mask").css({
		visibility : 'hidden'
	});
	$("#mask").hide();
}

// Used to collapse header/footer section in editor VF page
function collapseSection(sectionId) {
	sectionDiv = document.getElementById(sectionId).firstChild;
	if (sectionDiv.nextSibling.style.display != 'none') {
		section = sectionDiv.firstChild;
		twistSection(section);
	}
}

// Used in template test VF page
function startTemplateTest() {
	if (textAreaElement.value == '') {
		// alert(escape(textAreaElement.value));
		alert('Please enter first root object ids separated by comma without blank');
	} else {
		var url = "https://" + location.host
				+ "/apex/CtrlGenerateDocument?templateId=" + templateId
				+ "&rootIds=" + textAreaElement.value;
		location.href = url;
	}
}

// ********** Data Source and Data Sets *****************
// var map_objectName_objectLabel = new Array();
var map_dataSet_object = new Object();
var map_object_fields = new Object();
var map_objectNameFieldName_fieldLabel = new Object();

var rootObjectName;
var rootObjectLabel;

var dataSourceId;
var objectFieldsLoaded = false;

function parseObjectFields() {
	var objectNames = new Array(); // Contains only API names
	// var dataSetNames = new Array(); // Contains only dataSet names
	var objectsToSort = new Array(); // Contains labels and names used to
	// sort

	// We're creating a new template. The template data source is not yet
	// replicated to the server. Let's get it from the lookup field.
	if (templateId == '') {
		// The data source id should be populated in the lookup field
		var dataSourceId = document.getElementById(dataSourceField + '_lkid').value;

		if (dataSourceId == '' || dataSourceId == '000000000000000') {
			return;
		} else {

			// Get Data Source Details
			var query = "select Id, " + getNameSpacePrefix()
					+ "Root_Object__c from " + getNameSpacePrefix()
					+ "Template_Data_Source__c where Id = \'" + dataSourceId
					+ "\'";
			dataSourceResult = sforce.connection.query(query);
			dataSourceRecord = dataSourceResult.getArray("records");

			// Get Object Name
			if (isNameSpaceEmpty())
				rootObjectName = dataSourceRecord[0].Root_Object__c;
			else
				// @TODO namespace will change later
				rootObjectName = dataSourceRecord[0].TemplateVizArt__Root_Object__c;
		}
	} else {

		// Get Template Details
		var query = "select id, " + getNameSpacePrefix()
				+ "Template_Data_Source__c, " + getNameSpacePrefix()
				+ "Template_Data_Source__r." + getNameSpacePrefix()
				+ "Root_Object__c from " + getNameSpacePrefix()
				+ "Template__c where Id = \'" + templateId + "\'";
		templateResult = sforce.connection.query(query);
		templateRecord = templateResult.getArray("records");

		// Get Template Record incl. Data Source
		var template = templateRecord[0];

		// Generate set of objects
		if (isNameSpaceEmpty()) {
			rootObjectName = template.Template_Data_Source__r.Root_Object__c;
			dataSourceId = template.Template_Data_Source__c;
		} else {
			// @TODO namespace will change later
			rootObjectName = template.TemplateVizArt__Template_Data_Source__r.TemplateVizArt__Root_Object__c;
			dataSourceId = template.TemplateVizArt__Template_Data_Source__c;
		}
	}

	objectNames.push(rootObjectName);

	rootObjectLabel = sforce.connection.describeSObjects(objectNames)[0]['label'];

	// dataSetNames.push(rootObjectLabel);

	map_dataSet_object[rootObjectLabel] = rootObjectName;

	query = "select Id, Name, "
			+ getNameSpacePrefix()
			+ "Related_Object__c, "
			+ getNameSpacePrefix() 
			+ "Type__c, "
			+ getNameSpacePrefix()
			+ "Custom_SOQL__c from "
			+ getNameSpacePrefix()
			+ "Template_Data_Set__c where " 
			+ getNameSpacePrefix() 
			+ "Type__c in (\'Standard\', \'Custom SOQL\') and "
			+ getNameSpacePrefix() + "Template_Data_Source__c = \'"
			+ dataSourceId + "\' order by Name asc";

	dataSetResult = sforce.connection.query(query);
	dataSetRecords = dataSetResult.getArray("records");
	var soqlDataSets = new Array();

	for (d in dataSetRecords) {

		var dataSetName = dataSetRecords[d].Name;
		// dataSetNames.push(dataSetName);

		var recordType;
		if (isNameSpaceEmpty()) recordType = dataSetRecords[d].Type__c;
		else recordType = dataSetRecords[d].TemplateVizArt__Type__c;

		if (recordType == 'Standard') {
			// objectName only required for standard entries. in other cases
			// fields are retrieved from SOQL query
			var objectName;
			if (isNameSpaceEmpty())
				objectName = dataSetRecords[d].Related_Object__c;
			else
				objectName = dataSetRecords[d].TemplateVizArt__Related_Object__c;

			// Fill Map with DataSetName and ObjectName
			map_dataSet_object[dataSetName] = objectName;

			var found = false;
			if (objectName != '' && objectName != null) {
				for ( var i = 0; i < objectNames.length; i++) {
					if (objectNames[i] == objectName) {
						found = true;
					}
				}
				if (!found) {
					objectNames.push(objectName);
				}
			}
		} else if (recordType == 'Custom SOQL') {
			// Append suffix to distinguish from standard object names
			map_dataSet_object[dataSetName] = dataSetName + '__soql';
			if (isNameSpaceEmpty())
				soqlDataSets[dataSetName] = dataSetRecords[d].Custom_SOQL__c;
			else
				// @TODO namespace will change later
				soqlDataSets[dataSetName] = dataSetRecords[d].TemplateVizArt__Custom_SOQL__c;
		}
	}

	// Get Object Describes for Standard Data Sets
	var describeSObjectResult = sforce.connection.describeSObjects(objectNames);

	// Compose Field and Object Lists for Standard Data Sets
	for (r in describeSObjectResult) {
		var objectResult = describeSObjectResult[r];

		var fieldList = new Array();
		var fields = new Array();

		for (f in objectResult.fields) {
			var field = objectResult.fields[f];
			fieldList.push(field['label'] + "=" + field['name']);
		}

		fieldList.sort(arraySort);

		for (f in fieldList) {
			var strs = fieldList[f].split('=');
			var label = strs[0];
			var field = strs[1];
			map_objectNameFieldName_fieldLabel[objectResult['name'] + '.'
					+ field] = label;
			fields.push(field);
		}

		map_object_fields[objectResult['name']] = fields;
	}

	// Get Object Describes for SOQL Data Sets
	describeSObjectResult = sforce.connection.describeSObjects(soqlDataSets);

	map_soqlObject_fields = new Array();

	for (r in describeSObjectResult) {
		var describeResult = describeSObjectResult[r];
		map_soqlObject_fields[describeResult.name] = describeResult.fields;
	}

	// Compose field for Custom SOQL Data Sets
	for (ds in soqlDataSets) {
		var soql = soqlDataSets[ds].toLowerCase();

		// Determine select clause field list and split by comma into
		// selectFields array
		var searchPattern = /select[\\s]*?(.*?)[\\s]*?from/;

		searchPattern.exec(soql);

		var selectFields = RegExp.$1.split(',');

		var describeFieldList = map_soqlObject_fields[ds];

		var fieldList = new Array();
		var fields = new Array();

		for (f in selectFields) {
			// Split by whitespace in case we have an aggregation field
			var fieldNameAndAlias = trim(selectFields[f]).split(' ');
			var fieldAlias = trim(fieldNameAndAlias[fieldNameAndAlias.length - 1]);

			// Default fieldLabel to fieldAlias in case of aggregation fields we
			// use the alias
			var fieldLabel = fieldAlias;

			// Search for the field name (fieldAlias) in case we don't have an
			// aggregation field
			if (fieldNameAndAlias.length == 1) {
				for (df in describeFieldList) {
					var field = describeFieldList[df];
					if (field.name == fieldAlias) {
						fieldLabel = field.label;
					}
				}
			}
			// alert(fieldLabel + "=" + fieldAlias);

			fieldList.push(fieldLabel + "=" + fieldAlias);
		}

		fieldList.sort(arraySort);

		for (f in fieldList) {
			var strs = fieldList[f].split('=');
			var label = strs[0];
			var field = strs[1];
			map_objectNameFieldName_fieldLabel[ds + '__soql' + '.' + field] = label;
			fields.push(field);
		}

		map_object_fields[ds + '__soql'] = fields;
	}

	var objectFields = new Array();
	objectFields = fieldList;
	// map_objectName_objectLabel = dataSetNames;

	objectFieldsLoaded = true;
}

function setObjectFields() {

	CKEDITOR.dialog.getCurrent().getContentElement("MergeField", "objectField")
			.clear();

	var ds = CKEDITOR.dialog.getCurrent().getValueOf("MergeField", "sObject");
	var sobj = map_dataSet_object[ds];
	if (ds == rootObjectName) {
		sobj = rootObjectName;
	}
	// var sobj = map_dataSet_object[ds];

	var fields = map_object_fields[sobj];

	for (field in fields) {
		CKEDITOR.dialog.getCurrent().getContentElement("MergeField",
				"objectField").add(
				map_objectNameFieldName_fieldLabel[sobj + '.' + fields[field]],
				fields[field]);
	}

}

function setObjects() {
	var gotRootOO = false;
	for (ds in map_dataSet_object) {
		var value = ds;
		
		if (ds == rootObjectLabel && !gotRootOO) {
			value = rootObjectName;
			gotRootOO = true;
		}
		CKEDITOR.dialog.getCurrent().getContentElement("MergeField", "sObject").add(ds, value);
	}
}

function setLabelDataSets() {
	var gotRootOO = false;
	for (ds in map_dataSet_object) {
		var value = ds;
		
		if (ds == rootObjectLabel && !gotRootOO) {
			value = rootObjectName;
			gotRootOO = true;
		}
		CKEDITOR.dialog.getCurrent().getContentElement("Label", "sObject").add(ds, value);
	}
}

// ********** Function Library *****************
var itbFcts = new Array();
var map_itbFct_syntax = new Object();
var map_itbFct_details = new Object();

var itbFcts_name = new Array();
var itbFcts_type = new Array();
var itbFcts_syntax = new Array();
var itbFcts_details = new Array();

// Initialize function library for CKEditor custom button ItbFunctions
function initItbFcts() {

	if (itbFcts.length == 0) { // Only run if not yet initialized
		var fctAllRecords;

		if (isNameSpaceEmpty())
			fctAllRecords = sforce.apex.execute("ClsWebservice",
					"getFunctionHelp", {});
		else
			// @TODO namespace will change later
			fctAllRecords = sforce.apex.execute("TemplateVizArt.ClsWebservice",
					"getFunctionHelp", {});

		for ( var idx = 0; idx < fctAllRecords.length; idx++) {
			if (idx % 4 == 0) {
				itbFcts_name.push(fctAllRecords[idx]);
			} else if (idx % 4 == 1) {
				itbFcts_type.push(fctAllRecords[idx]);
			} else if (idx % 4 == 2) {
				itbFcts_syntax.push(fctAllRecords[idx]);
			} else if (idx % 4 == 3) {
				itbFcts_details.push(fctAllRecords[idx]);
			}
		}

		var prevType;

		for (idx = 0; idx < itbFcts_name.length; idx++) {
			var cFct = itbFcts_name[idx];
			var cType = itbFcts_type[idx];
			var cSynt = itbFcts_syntax[idx];
			var cDetl = itbFcts_details[idx];

			if (cType != prevType) { // Add new type section
				itbFcts.push('--- ' + cType + ' ---');
				prevType = cType;
			}

			itbFcts.push(cFct);
			map_itbFct_syntax[cFct] = cSynt;
			map_itbFct_details[cFct] = cDetl;
		}

	}

}

// Import function library into CKEditor
function getItbFunctions() {
	initItbFcts();
	for (i in itbFcts) {
		var f = itbFcts[i];
		CKEDITOR.dialog.getCurrent().getContentElement("ItbFunctions", "fct")
				.add(f, f);
	}

}

// Inserts selected function into textarea pane
function injectItbFunction() {
	editor = this.getParentEditor();

	var f = this.getContentElement('ItbFunctions', 'fct').getInputElement()
			.getValue();

	var fct = map_itbFct_syntax[f];

	if (f != 'n/a' && f.substr(0, 3) != '---') {
		// Check the active editing mode.
		if (editor.mode == 'wysiwyg') {
			// Insert the desired HTML.
			editor.insertText(fct);
		} else
			alert('You must be on WYSIWYG mode!');
	} else
		alert('Please select a function!');
}

function showItbFctDesc() {
	var descDiv = document.getElementById(descPaneId);
	var f = CKEDITOR.dialog.getCurrent().getValueOf("ItbFunctions", "fct");

	if (f != 'n/a' && f.substr(0, 3) != '---') {
		var descText;

		/*
		 * if (map_itbFct_details[f] == null || map_itbFct_details[f] == '') { //
		 * Need to retrieve description from SFDC label via web service descText =
		 * sforce.apex.execute("TemplateVizArt.WsTranslations", "getFunctionHelp",
		 * {name:f}); map_itbFct_details[f] = descText; } else { // Already
		 * retrieved, don't need it again descText = map_itbFct_details[f]; }
		 * 
		 * descText = String(descText);
		 */

		descText = String(map_itbFct_details[f]);

		if (descText == null || descText == '') { // No description found
			descText = 'Description not found! Please contact your administrator.';
		}

		descDiv.value = descText.wordWrap(73, "\n", 1);

	} else {
		descDiv.value = 'Please select a function to display detailed information.';
	}
}

/**
 * get the 'value' attribute from a specified <input> html tag 
 * @param str 		specified html String 
 * @param inputId  	specified 'id' attribute value in an <input> html tag
 * @return 			'value' attribute from the <input> html tag, whose 'id' equals the given 'inputId'
 */
function getValueAttributeOfInputTag(htmlStr, inputId, isHidden) 
{

	var result = '';

	if(htmlStr && htmlStr.length > 0) {
		var reg;
		if(isHidden) {
			reg = new  RegExp("[^>]*<input [^>]*type=\"hidden\" [^>]*id=\"" + inputId + "\"[^>]*>", "g");			
		} else {
			reg = new  RegExp("[^>]*<input [^>]*id=\"" + inputId + "\"[^>]*>", "g");							
		}
		var tmp =  reg.exec(htmlStr);
		if(tmp && tmp.length == 1) {
		reg = /value="[\d\D]*"/g;
		result = reg.exec(tmp);
			if(result && result.length == 1) {
				result = result[0].substring("value=\"".length, result[0].length - 1);
				result = HTMLDecode(result);
			}	
		}
	} 	
	return result;
}

function getValueOfHtmlTag(htmlStr, id) 
{

	var result = '';

	if(htmlStr && htmlStr.length > 0) {
		//var reg = new  RegExp("[^>]*<" +htmlTag + " [^>]*id=\"" + id + "\"[\d\D]*/" + htmlTag + ">", "g");
		var reg = new  RegExp("<textarea [^>]*id=\"" + id + "\" [^/]*</textarea>", "gi");										
		var tmp =  reg.exec(htmlStr);
		if(tmp && tmp.length == 1) {
			  reg = new RegExp("<(.| )+?>", "gim");
              result = tmp[0].replace(reg, "");
              result = HTMLDecode(result);
		} 
	}

	return result;
}

// ********** Help Functions *****************
String.prototype.wordWrap = function(m, b, c) {
	var i, j, l, s, r;
	if (m < 1)
		return this;
	for (i = -1, l = (r = this.split("\n")).length; ++i < l; r[i] += s)
		for (s = r[i], r[i] = ""; s.length > m; r[i] += s.slice(0, j)
				+ ((s = s.slice(j)).length ? b : ""))
			j = c == 2 || (j = s.slice(0, m + 1).match(/\S*(\s)?$/))[1] ? m
					: j.input.length - j[0].length || c == 1 && m
							|| j.input.length
							+ (j = s.slice(m).match(/^\S*/)).input.length;

	// Trim lines
	for (i = 0; i < r.length; i++) {
		var lines = r[i].split(b);
		var tl = '';
		for (l in lines) {
			tl += trim(lines[l]) + "\n";
		}
		r[i] = tl;
	}

	return r.join("\n");
};

function arraySort(x, y) {
	var a = String(x).toUpperCase();
	var b = String(y).toUpperCase();
	if (a > b)
		return 1;
	if (a < b)
		return -1;
	return 0;
}

function trim(str, chars) {
	return ltrim(rtrim(str, chars), chars);
}

function ltrim(str, chars) {
	chars = chars || "\\s";
	return str.replace(new RegExp("^[" + chars + "]+", "g"), "");
}

function rtrim(str, chars) {
	chars = chars || "\\s";
	return str.replace(new RegExp("[" + chars + "]+$", "g"), "");
}

/**
 * if namespace is not empty, return namepace + '__' namespacePrefix will be
 * used in soql query
 */
function getNameSpacePrefix() {
	if (namespace != null && namespace != undefined
			&& namespace.length > 0)
		return namespace + '__';
	else
		return '';
}

/**
 * check whether variable 'namespace' empty or not. the varibale is passed from
 * apex component.
 */
function isNameSpaceEmpty() {
	if (namespace != null && namespace != undefined
			&& namespace.length > 0)
		return false;
	else
		return true;
}

/**
 * convert HTML Entity to Symbols or Punctuations
 * eg. '&glt;' -> '<'
 */
function HTMLDecode(input)
{
	var converter = document.createElement("div");
	converter.innerHTML = input;
	var output = converter.innerText; //for ie, chrome ...
	
	if(!output) 
		output = converter.textContent; // for firefox 
	
	converter = null;
	return output;
}
