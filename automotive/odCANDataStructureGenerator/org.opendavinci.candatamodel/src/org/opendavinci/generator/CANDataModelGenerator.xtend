/**
 * CANDataStructureGenerator - IDL tool to describe the mapping from
 *                             CAN data to high-level messages.
 * Copyright (C) 2015 Christian Berger
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package org.opendavinci.generator

import java.util.ArrayList
import java.util.HashMap
import java.util.Iterator
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.opendavinci.canDataModel.CANSignal
import org.opendavinci.canDataModel.CANSignalMapping

class CANDataModelGenerator implements IGenerator {

	/* This class describes all data to a defined CAN signal in a .can file. */
	static class CANSignalDescription {
		String m_FQDN
		String m_CANID
		String m_startBit
		String m_length
		String m_lengthBytes
		String m_endian
		String m_multiplyBy
		String m_add
		String m_rangeStart
		String m_rangeEnd
	}
	
    /* This method is our interface to an outside caller. */
	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		val generatedHeadersFile = resource.URI.toString().substring(resource.URI.toString().lastIndexOf("/") + 1).replaceAll(".can", "")

		// First, extract all CAN signals from .can file.
		val mapOfDefinedCANSignals = collectDefinedCANSignals(resource.allContents.toIterable.filter(typeof(CANSignal)))
		
		// needed for the "super" header and source files
		var ArrayList<String> includedClasses=new ArrayList<String>
		for (e : resource.allContents.toIterable.filter(typeof(CANSignalMapping))) {
			includedClasses.add(e.mappingName.toString().replaceAll("\\.", "/"))
		}
		
		fsa.generateFile("include/GeneratedHeaders_" + generatedHeadersFile + ".h", generateSuperHeaderFileContent(generatedHeadersFile, includedClasses))
		fsa.generateFile("src/GeneratedHeaders_" + generatedHeadersFile + ".cpp", generateSuperImplementationFileContent(generatedHeadersFile, includedClasses))
		
		// Next, generate the code for the actual mapping.
		for (e : resource.allContents.toIterable.filter(typeof(CANSignalMapping))) {
			fsa.generateFile("include/generated/" + e.mappingName.toString().replaceAll("\\.", "/") + ".h", generateHeaderFileContent(generatedHeadersFile, e))
			fsa.generateFile("src/generated/" + e.mappingName.toString().replaceAll("\\.", "/") + ".cpp", 
				generateImplementationFileContent(e, "generated", mapOfDefinedCANSignals))
			fsa.generateFile("testsuites/" + e.mappingName.toString().replaceAll("\\.", "_") + "TestSuite.h", generateTestSuiteContent(generatedHeadersFile, e))
			fsa.generateFile("uppaal/generated/" + e.mappingName.toString().replaceAll("\\.", "/"), generateUPPAALFileContent(e))
		}
	}

	/* This method collects all CAN signal definitions. */
	def collectDefinedCANSignals(Iterable<CANSignal> iter) {
		val cansignalsByFQDN =  new HashMap<String, CANSignalDescription>
		val localIterator = iter.iterator
		while (localIterator.hasNext) {
			val cs = localIterator.next
			val csd = new CANSignalDescription
			csd.m_FQDN = cs.cansignal
			csd.m_CANID = cs.canIdentifier
			csd.m_startBit = cs.startBit
			csd.m_length = cs.length
			if((cs.length==null || cs.length=="") && (cs.lengthBytes!=null || cs.lengthBytes!=""))
				csd.m_length = (Integer.parseInt(cs.lengthBytes)*8)+""
			csd.m_lengthBytes = cs.lengthBytes
			if((cs.lengthBytes==null || cs.lengthBytes=="") && (cs.length!=null || cs.length!="") && Integer.parseInt(cs.length)%8==0)
				csd.m_lengthBytes = (Integer.parseInt(cs.length)/8)+""
			csd.m_endian = cs.endian
			csd.m_multiplyBy = cs.multiplyBy
			csd.m_add = cs.add
			csd.m_rangeStart = cs.rangeStart
			csd.m_rangeEnd = cs.rangeEnd
			cansignalsByFQDN.put(csd.m_FQDN, csd)
		}
        return cansignalsByFQDN
	}

    /* This method generates the header file content. */
	def generateSuperHeaderFileContent(String generatedHeadersFile, ArrayList<String> includedClasses) '''
/*
 * This software is open source. Please see COPYING and AUTHORS for further information.
 *
 * This file is auto-generated. DO NOT CHANGE AS YOUR CHANGES MIGHT BE OVERWRITTEN!
 */

#ifndef GENERATEDHEADERS_«generatedHeadersFile.toUpperCase()»_H_
#define GENERATEDHEADERS_«generatedHeadersFile.toUpperCase()»_H_

#include <string>
#include <vector>

«FOR include : includedClasses»
#include "generated/«include».h"
«ENDFOR»

#include <core/data/Container.h>

#include "GeneratedHeaders_AutomotiveData.h"

namespace canmapping {

    using namespace std;

    class CanMapping {
        private:
            /**
             * "Forbidden" copy constructor. Goal: The compiler should warn
             * already at compile time for unwanted bugs caused by any misuse
             * of the copy constructor.
             *
             * @param obj Reference to an object of this class.
             */
            CanMapping(const CanMapping &/*obj*/);

            /**
             * "Forbidden" assignment operator. Goal: The compiler should warn
             * already at compile time for unwanted bugs caused by any misuse
             * of the assignment operator.
             *
             * @param obj Reference to an object of this class.
             * @return Reference to this instance.
             */
            CanMapping& operator=(const CanMapping &/*obj*/);

        public:
            CanMapping();

            virtual ~CanMapping();

            /**
             * This method adds the given GenericCANMessage to the internal
             * CAN message decoder. If this message could be decoded (or
             * including the previous sequence, this method returns a valid
             * Container (ie. Container::UNDEFINEDDATA).
             *
             * @param gcm Next GenericCANMessage.
             * @return Container, where the type needs to be checked to determine invalidity (i.e. !Container::UNDEFINEDDATA).
             */
            vector<core::data::Container> mapNext(const ::automotive::GenericCANMessage &gcm);

        private:
        
			«FOR include : includedClasses»
			«var String className=include.split('\\/').get(include.split('\\/').size-1)»
				«include.replaceAll('\\/','::')» m_«Character.toLowerCase(className.charAt(0)) + className.substring(1)»;
			«ENDFOR»
		
    };

} // canmapping

#endif /*GENERATEDHEADERS_«generatedHeadersFile.toUpperCase()»_H_*/
'''

    /* This method generates the header file content. */
	def generateSuperImplementationFileContent(String generatedHeadersFile, ArrayList<String> includedClasses) '''
/*
 * This software is open source. Please see COPYING and AUTHORS for further information.
 *
 * This file is auto-generated. DO NOT CHANGE AS YOUR CHANGES MIGHT BE OVERWRITTEN!
 */

«FOR include : includedClasses»
#include "generated/«include».h"
«ENDFOR»

#include "GeneratedHeaders_«generatedHeadersFile».h"

namespace canmapping {


«var ArrayList<String> members=new ArrayList<String>»
«var Iterator<String> iter = includedClasses.iterator»
«{var String member;
	while (iter.hasNext()){
	member=iter.next();
	var String className=member.split('\\/').get(member.split('\\/').size-1)
	var String temp="m_"+Character.toLowerCase(className.charAt(0)) + className.substring(1)+" ()";
	if(iter.hasNext())temp+=",";
	members.add(temp);
}}»
    CanMapping::CanMapping() :
    «FOR member:members»
    «member»
    «ENDFOR»
{}

    CanMapping::~CanMapping() {}

    vector<core::data::Container> CanMapping::mapNext(const ::automotive::GenericCANMessage &gcm) {
        vector<core::data::Container> listOfContainers;

        // Traverse all defined mappings and check whether a new high-level message could be fully decoded.
	    «FOR member:members»
	    {
	    	core::data::Container container = «member.substring(0,member.indexOf(" ()"))».decode(gcm);
	    	if (container.getDataType() != core::data::Container::UNDEFINEDDATA)
	    	{
	    		listOfContainers.push_back(container);
	    	}
	    }
	    «ENDFOR»

        return listOfContainers;
    }

} // canmapping
'''

	def generateHeaderFileBody(String className) '''
    using namespace std;

    class «className» : public core::data::SerializableData, public core::base::Visitable {
        private:
            /**
             * "Forbidden" copy constructor. Goal: The compiler should warn
             * already at compile time for unwanted bugs caused by any misuse
             * of the copy constructor.
             *
             * @param obj Reference to an object of this class.
             */
            «className»(const «className» &/*obj*/);

            /**
             * "Forbidden" assignment operator. Goal: The compiler should warn
             * already at compile time for unwanted bugs caused by any misuse
             * of the assignment operator.
             *
             * @param obj Reference to an object of this class.
             * @return Reference to this instance.
             */
            «className»& operator=(const «className» &/*obj*/);

        public:
            «className»();

            virtual ~«className»();

            core::data::Container decode(const ::automotive::GenericCANMessage &gcm);

            virtual const string toString() const;
    
    		virtual ostream& operator<<(ostream &out) const;
    
    		virtual istream& operator>>(istream &in);

    		virtual void accept(core::base::Visitor &v);
    		
        private:
        	std::map<uint64_t,uint64_t> m_payloads;
        	std::vector<uint64_t> m_neededCanMessages;
        	uint64_t m_index;
    }; // end of class "«className»"
    
	'''

	def generateHeaderFileNSs(String[] namespaces, int i) '''
	«IF namespaces.size>i+1»
	namespace «namespaces.get(i)» {
		«generateHeaderFileNSs(namespaces, i+1)»
	} // end of namespace "«namespaces.get(i)»"
	«ELSE»
	«generateHeaderFileBody(namespaces.get(i))»
	«ENDIF»
	'''

    /* This method generates the header file content. */
	def generateHeaderFileContent(String generatedHeadersFile, CANSignalMapping mapping) '''
/*
 * This software is open source. Please see COPYING and AUTHORS for further information.
 *
 * This file is auto-generated. DO NOT CHANGE AS YOUR CHANGES MIGHT BE OVERWRITTEN!
 */
// Header file for: «mapping.mappingName.toString»
#ifndef «mapping.mappingName.toString.toUpperCase.replaceAll("\\.", "_")»_H_
#define «mapping.mappingName.toString.toUpperCase.replaceAll("\\.", "_")»_H_

#include <core/data/Container.h>
#include <core/base/Visitable.h>
#include <core/data/SerializableData.h>

#include "GeneratedHeaders_AutomotiveData.h"

namespace canmapping {
	«var String[] classNames = mapping.mappingName.toString.split('\\.')»
	«IF classNames.size>1»
		«generateHeaderFileNSs(classNames, 0)»
	«ELSE»
		«generateHeaderFileBody(classNames.get(0))»
	«ENDIF»
} // end of namespace canmapping

#endif /*«mapping.mappingName.toString.toUpperCase.replaceAll("\\.", "_")»_H_*/
'''

	def generateImplementationFileNSs(String[] namespaces, int i, CANSignalMapping mapping, String includeDirectoryPrefix, HashMap<String, CANSignalDescription> canSignals, ArrayList<String> canIDs) '''
	«IF namespaces.size>i+1»
	namespace «namespaces.get(i)» {
		«generateImplementationFileNSs(namespaces, i+1, mapping, includeDirectoryPrefix, canSignals, canIDs)»
	} // end of namespace "«namespaces.get(i)»"
	«ELSE»
	«generateImplementationFileBody(namespaces.get(i), mapping, includeDirectoryPrefix, canSignals, canIDs)»
	«ENDIF»
	'''
	
	def generateImplementationFileBody(String className, CANSignalMapping mapping, String includeDirectoryPrefix, HashMap<String, CANSignalDescription> canSignals, ArrayList<String> canIDs) '''
	
	using namespace std;

	«className»::«className»() :
		SerializableData(),
		m_payloads(),
		m_neededCanMessages(),
		m_index(0)
	{
		«FOR id : canIDs»
		m_neededCanMessages.push_back(«id»);
        «ENDFOR»
	}
	
	«className»::~«className»() {}
	
	const string «className»::toString() const {
		string result = "Class : «className» \n";
		return result;
	}
	
	ostream& «className»::operator<<(ostream &out) const {
		return out;
	}
	
	istream& «className»::operator>>(istream &in) {
		return in;
	}
	
	void «className»::accept(core::base::Visitor &v) {
		(void)v;
	}
	
	core::data::Container «className»::decode(const ::automotive::GenericCANMessage &gcm) {
		core::data::Container c;
		switch(gcm.getIdentifier())
		{
			// order check should be done here
	    	«FOR id : canIDs»
	    	case «id» : 
	    	
	    	«IF mapping.unordered!=null && mapping.unordered.compareTo("unordered")==0»
	    	// if the order doesn't matter, store the payload in a map for future use replacing the current content held there
	    	m_payloads[gcm.getIdentifier()] = gcm.getData();
	    	«ELSE»
	    	// if the order matters:
	    	if(m_neededCanMessages.at(m_index) == «id») // if we got the expected message
	    	{
	    		// Store the payload in a map for future use replacing the current content
	    		m_payloads[«id»] = gcm.getData();
	    		// modularly increase the internal index
	    		(m_index==m_neededCanMessages.size()-1) ? m_index=0 : ++m_index;
	    	}
	    	else // otherwise
	    	{
	    		// reset the payloads map
	    		while(! m_payloads.empty())
	    			m_payloads.erase(m_payloads.begin());
	    		// reset the internal index
	    		m_index=0;
	    	}
	    	«ENDIF»
	    	break;
	    	
	        «ENDFOR»
	        default : return c; // valid id not found
	    }
	    
		// if we don't have all the needed CAN messages, return 
		if(m_payloads.size()!=m_neededCanMessages.size())
			return c;

		// 1. Create a generic message.
		core::reflection::Message message;
	
		«FOR currenMapping : mapping.mappings»
		«var String signalName=currenMapping.cansignal»
		// addressing signal «signalName»
		{
			// 2. Get the raw payload.
			uint64_t data = m_payloads[«canSignals.get(signalName).m_CANID»];
	
			// 3. Map uin64_t value to 8 byte uint8_t array.
			//uint8_t payload[8]=reinterpret_cast<uint8_t*>(&data);
	
			«var String tempVarType=""»
			«var String tempVarName="raw_"+signalName.replaceAll("\\.", "_")»
			«var String finalVarName="transformed_"+signalName.replaceAll("\\.", "_")»
			
			// 4.1 Get raw value from attribute.
			«tempVarType="uint64_t"» «tempVarName»=0x0000000000000000;
			«tempVarName»=data;
			
			// reset left-hand side of bit field
			«tempVarName»=«tempVarName» << «Integer.parseInt(canSignals.get(signalName).m_startBit)»;
			// reset right-hand side of bit field
			«tempVarName»=«tempVarName» >> «63-Integer.parseInt(canSignals.get(signalName).m_length)»;
			«IF canSignals.get(signalName).m_endian.compareTo("big")==0»
			
			// 4.2 Optional: Fix endianness depending on CAN message specification.
			«tempVarName» = ntohs(«tempVarName»);
			«ELSE»
			
			// 4.2 Endianness doesn't need fixing, skipping this step.
			«ENDIF»
	
			// variable holding the transformed value
			double «finalVarName»=static_cast<double>(«tempVarName»);
			
			// 4.3 Apply value transformation (i.e. formula) to map raw value to (physically) meaningful value according to CAN message specification.
			// scaling
			const double SCALE = «canSignals.get(signalName).m_multiplyBy»;
			«finalVarName»=«finalVarName»*SCALE;
			// adding
			const double OFFSET = «canSignals.get(signalName).m_add»;
			«finalVarName»=«finalVarName»+OFFSET;
			
			// clamping
			if(«finalVarName»<«canSignals.get(signalName).m_rangeStart»)
				«finalVarName»=«canSignals.get(signalName).m_rangeStart»;
			else if(«finalVarName»>«canSignals.get(signalName).m_rangeEnd»)
				«finalVarName»=«canSignals.get(signalName).m_rangeEnd»;
			
			// 4.4 Create a field for a generic message.
			core::reflection::Field<double> *f = new core::reflection::Field<double>(«finalVarName»);
			f->setLongIdentifier(«canSignals.get(signalName).m_CANID»); // The identifiers specified here must match with the ones defined in the .odvd file!
			f->setShortIdentifier(static_cast<uint8_t>(«canSignals.get(signalName).m_CANID»)); // The identifiers specified here must match with the ones defined in the .odvd file!
			f->setLongName("«canSignals.get(signalName).m_FQDN»");
			f->setShortName("«{var String[] res; res=canSignals.get(signalName).m_FQDN.split("\\."); res.get(res.size-1)}»");
			f->setFieldDataType(coredata::reflection::AbstractField::DOUBLE_T);
			f->setSize(sizeof(«finalVarName»));
	
			// 4.5 Add created field to generic message.
			message.addField(core::SharedPointer<coredata::reflection::AbstractField>(f));
		}
	«ENDFOR»
		// 5. Depending on the CAN message specification, we are either ready here
		// (i.e. mapping one CAN message to one high-level C++ message), or we have
		// to wait for more low-level CAN messages to complete this high-level C++ message.
		// Thus, our state machine would have to store this (incomplete) "message"
		// variable internally to continue decoding later.
		
		{
			// 6. As we are ready here for the given example, we create a visitor to
			// traverse the unnamed message and create a named message (i.e. an instance
			// of a high-level C++ message) to be distributed as a Container.
			core::reflection::MessageToVisitableVisitor mtvv(message);
			
			// 7. Create an instance of the named high-level message.
            «var String HLName= (Character.toLowerCase(mapping.mappingName.toString.charAt(0)) + mapping.mappingName.toString.substring(1)).replaceAll("\\.", "_")»
            «mapping.mappingName.toString.replaceAll("\\.", "::")» «HLName»;
	
			// 8. Letting the high-level message accept the visitor to enter the values.
            «HLName».accept(mtvv);

			// 9. Create the resulting container carrying a valid payload.
			c = core::data::Container(core::data::Container::USER_DATA_9, «HLName»);
		}
		return c;
	}
	
	'''
	
	/* This method generates the implementation (.cpp). */
	def generateImplementationFileContent(CANSignalMapping mapping, String includeDirectoryPrefix, HashMap<String, CANSignalDescription> canSignals) '''
/*
 * This software is open source. Please see COPYING and AUTHORS for further information.
 *
 * This file is auto-generated. DO NOT CHANGE AS YOUR CHANGES MIGHT BE OVERWRITTEN!
 */
// Source file for: «mapping.mappingName.toString»

«var ArrayList<String> canIDs=new ArrayList<String>»
/*
signals of interest:

«IF(mapping.mappings.size>0)»
«FOR currenMapping : mapping.mappings»
«currenMapping.cansignal»
«ENDFOR»
«ELSE»
none.
«ENDIF»

«FOR currenMapping : mapping.mappings»
«var String signalName=currenMapping.cansignal»
«var CANSignalDescription canSignal=canSignals.get(signalName)»
«var String[] splittedMN=mapping.mappingName.toString.toLowerCase.split("\\.")»
«IF(splittedMN.get(splittedMN.size-1).compareTo(signalName.split("\\.").get(0).toLowerCase)==0)»
«{
	var boolean test=true;
	for(id:canIDs)
		if(id.compareTo(canSignal.m_CANID)==0)
			test=false;
	if(test)
		canIDs.add(canSignal.m_CANID);
	""
}»
CANID       : «canSignal.m_CANID»
FQDN        : «canSignal.m_FQDN»
startBit    : «canSignal.m_startBit»
length      : «canSignal.m_length»
lengthBytes : «canSignal.m_lengthBytes»
endian      : «canSignal.m_endian»
multiplyBy  : «canSignal.m_multiplyBy»
add         : «canSignal.m_add»
rangeStart  : «canSignal.m_rangeStart»
rangeEnd    : «canSignal.m_rangeEnd»

«ENDIF»
«ENDFOR»
*/

#include "generated/«mapping.mappingName.toString.replaceAll('\\.','/')».h"

#include <core/SharedPointer.h>
#include <core/reflection/Message.h>
#include <core/reflection/MessageToVisitableVisitor.h>

namespace canmapping {

	«var String[] classNames = mapping.mappingName.toString.split('\\.')»
	«IF classNames.size>1»
		«generateImplementationFileNSs(classNames, 0, mapping, includeDirectoryPrefix, canSignals, canIDs)»
	«ELSE»
		«generateImplementationFileBody(classNames.get(0), mapping, includeDirectoryPrefix, canSignals, canIDs)»
	«ENDIF»

} // canmapping
'''

	// Generate the test suite content (.h).	
	def generateTestSuiteContent(String generatedHeadersFile, CANSignalMapping mapping) '''
/*
 * This software is open source. Please see COPYING and AUTHORS for further information.
 *
 * This file is auto-generated. DO NOT CHANGE AS YOUR CHANGES MIGHT BE OVERWRITTEN!
 */
// Test suite file for: «mapping.mappingName.toString»

#ifndef CANMAPPINGTESTSUITE_H_
#define CANMAPPINGTESTSUITE_H_

#include "cxxtest/TestSuite.h"

using namespace std;

/**
 * The actual testsuite starts here.
 */
class CANBridgeTest : public CxxTest::TestSuite {
    public:
        void testSample() {
            TS_ASSERT(1 != 0);
        }


};

#endif /*CANMAPPINGTESTSUITE_H_*/
'''

    /* This method generates the UPPAAL file content. */
	def generateUPPAALFileContent(CANSignalMapping mapping) '''
<!--
This software is open source. Please see COPYING and AUTHORS for further information.

This file is auto-generated. DO NOT CHANGE AS YOUR CHANGES MIGHT BE OVERWRITTEN!
-->
<!-- UPPAAL file for: «mapping.mappingName.toString» -->
'''
}
