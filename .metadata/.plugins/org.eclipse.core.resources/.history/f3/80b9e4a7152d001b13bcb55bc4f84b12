/**
* Name: task2
* Based on the internal empty template. 
* Author: Zidi Chen, Sihan Chen
* Tags: 
*/


model task2
global{
	int number_of_stages <- 4;
	int number_of_guests <- 10;
	list<Stage> stages;
	list<Guest> guests;
	list<point> stagePositions;
	list<string> themes <- ['concert','magic show','band','dance'];
	int themePointer <- 0;
	
	init{
		
		create Stage number:1{
			location <- {25,25};
			
			self.position <- location;
			
			stagePositions << location;
			stages << self;
			self.themeId <- 0;
		}
		create Stage number:1{
			location <- {75,75};
			
			self.position <- location;
			
			stagePositions << location;
			stages << self;
			self.themeId <- 1;
		}
		create Stage number:1{
			location <- {25,75};
			
			self.position <- location;
			
			stagePositions << location;
			stages << self;
			self.themeId <- 2;
		}
		create Stage number:1{
			location <- {75,25};
			
			self.position <- location;
			
			stagePositions << location;
			stages << self;
			self.themeId <- 3;
		}
		create Guest number:number_of_guests{
			guests << self;
		}
		
		
	}
	
	
}
	species Stage skills:[fipa]{
		int themeId;
		string theme;
		point position;
		
		rgb color;
		
		int timer <- 0 update: timer + 1;
		
		//factors of the stage
		float flightShow;
		float fmusic;
		float fspeaker;
		float fband;
		float fvisual;
		float fdecoration;
		
		init{
			
		}
		
		
		reflex updateTheme when:(timer mod 100) = 0 or timer = 1{
			self.theme <- themes[themeId];
			themeId <- themeId + 1;
			if(themeId = 4){
				themeId <- 0;
			}
			
			write '[' + self + ']: update theme to ' + theme;
			
			if(theme = 'concert'){
				flightShow <- 3.0;
				fmusic <- 9.0;
				fspeaker <- 8.0;
				fband <- 6.0;
				fvisual <- 5.0;
				fdecoration <- 2.0;
				
				color <- #yellow;
			}else if(theme = 'magic show'){
				flightShow <- 6.0;
				fmusic <- 3.0;
				fspeaker <- 5.0;
				fband <- 2.0;
				fvisual <- 9.0;
				fdecoration <- 8.0;
				
				color <- #grey;
			}else if(theme = 'band'){
				flightShow <- 3.0;
				fmusic <- 8.0;
				fspeaker <- 6.0;
				fband <- 9.0;
				fvisual <- 5.0;
				fdecoration <- 2.0;
				
				color <- #blue;
			}else if(theme = 'dance'){
				flightShow <- 3.0;
				fmusic <- 8.0;
				fspeaker <- 6.0;
				fband <- 2.0;
				fvisual <- 9.0;
				fdecoration <- 5.0;
				
				color <- #purple;
			}else{
				write '[' + self + ']: I am not sure what is my stage theme' + theme;
				color <- #black;
			}
			
			write 'factors of [' + self + ']: lightShow ' + flightShow + ', music ' + fmusic 
			+ ', speaker ' + fspeaker + ', band ' + fband + ', visual ' + fvisual + ', decoration ' + fdecoration;   
	
			
			do start_conversation (to: guests , protocol: 'no-protocol', performative: 'inform', contents: [flightShow,fmusic,fspeaker,fband,fvisual,fdecoration]);
		}
		
		aspect base{
			draw circle(10) color: color;
		}
	}
	
	species Guest skills:[fipa, moving]{
		
		
		
		//perferences of the param
		float plightShow;
		float pmusic;
		float pspeaker;
		float pband;
		float pvisual;
		float pdecoration;
		
		Stage targetStage <- nil;
		list<float> utilityList <- [0.0,0.0,0.0,0.0];
		
		init{
				plightShow <- rnd(0.0,10.0);
				pmusic <- rnd(0.0,10.0);
				pspeaker <- rnd(0.0,10.0);
				pband <- rnd(0.0,10.0);
				pvisual <- rnd(0.0,10.0);
				pdecoration <- rnd(0.0,10.0);
				write 'perferences of [' + self + ']: lightShow ' + plightShow + ', music ' + pmusic 
				+ ', speaker ' + pspeaker + ', band ' + pband + ', visual ' + pvisual + ', decoration ' + pdecoration;   
		
			}
		
		
		reflex calculatUtility when:!empty(informs){
			list<message> msg <- informs;
			loop m over: msg{
				list content <- list(m.contents);
				float f0 <- float(content[0]);
				float f1 <- float(content[1]);
				float f2 <- float(content[2]);
				float f3 <- float(content[3]);
				float f4 <- float(content[4]);
				float f5 <- float(content[5]);
				
				float utility <- f0*plightShow + f1*pmusic + f2*pspeaker 
					+ f3*pband + f4*pvisual + f5*pdecoration;
					
				if(m.sender = stages[0]){
					utilityList[0] <- utility;
				}
				if(m.sender = stages[1]){
					utilityList[1] <- utility;
				}
				if(m.sender = stages[2]){
					utilityList[2] <- utility;
				}
				if(m.sender = stages[3]){
					utilityList[3] <- utility;
				}
					
//				write '[' + self + ']: ' + m.sender + ', utility' + utility;
	
			}

			write '[' + self + '] utility list: ' + utilityList;
			
			
			float maxUtility <- 0.0;
			int i <- 0;
			int pointer <- 0;
			loop u over:utilityList{
				if(u > maxUtility){
					maxUtility <- u;
					pointer <- i;
				}
				i <- i + 1;
			}
			
			
			targetStage <- stages[pointer];
			

			
			write '[' + self + '] max utility: ' + maxUtility;
			write '[' + self + '] target stage: ' + targetStage;	
			
					

		}
		
		reflex wander when:targetStage != nil and location distance_to targetStage <= 10{
			do wander;
		}
		
		reflex gotoTargetStage when:targetStage != nil and location distance_to targetStage > 10{
			do goto target:targetStage;
		}
		
		aspect base{
			draw sphere(2) color: #red;
		}
	}
	
	experiment main type:gui{
	output{
		display map type:opengl{
			
			species Stage aspect:base;
			species Guest aspect:base;
		}
	}
	
}
	


