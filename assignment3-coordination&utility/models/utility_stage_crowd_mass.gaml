/**
* Name: task2
* Based on the internal empty template. 
* Author: Zidi Chen, Sihan Chen
* Tags: 
*/


model task2_bonus
global{
	int number_of_stages <- 4;

	float fcrowd <- 100.0;
	
	list<Guest> guestsWithoutLeader;
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
		create Guest number:2{
			isLeader <- false;
			guests << self;
			guestsWithoutLeader<<self;
		}
		create Guest number:1{
			isLeader <- true;
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
			
	//		write '[' + self + ']: update theme to ' + theme;
			
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
	//			write '[' + self + ']: I am not sure what is my stage theme' + theme;
				color <- #black;
			}
			
	//		write 'factors of [' + self + ']: lightShow ' + flightShow + ', music ' + fmusic 
	//		+ ', speaker ' + fspeaker + ', band ' + fband + ', visual ' + fvisual + ', decoration ' + fdecoration;   
	
			
			do start_conversation (to: guests , protocol: 'fipa-contract-net', performative: 'cfp', contents: [flightShow,fmusic,fspeaker,fband,fvisual,fdecoration]);
		}
		
		aspect base{
			draw circle(10) color: color;
		}
	}
		
	species Guest skills:[fipa, moving]{

		rgb color;
		
		//perferences of the param
		float plightShow;
		float pmusic;
		float pspeaker;
		float pband;
		float pvisual;
		float pdecoration;
		
		//prefer crowd or not
		bool preferCrowd <- flip(0.5);
		
		//how much I emphasize on crowd factor
		float pcrowd;
		
		Stage initTargetStage <- nil;
		Stage finalTargetStage <- nil;
		
		
		//my utility on four stages without considering crowd factor
		list<float> utilityList <- [0.0,0.0,0.0,0.0];
		
		bool sendAttribute <- false;
		bool hasFinalTarget <- false;
		
		

		//attributes for leader
		bool isLeader;
		float totalUtility <- 0.0;
		list<Stage> guestTargetList;
		map<Stage,int> stageCounter;
		
		//all guests prefer crowd or not
		map<Guest, bool> crowdPreferenceList;
		//how much all guests emphasize on crowd factor
		map<Guest, float> pcrowdList;
		//utility of all the guests on four stages without considering crowd factor
		map<Guest, map<Stage,float>> guestUtilityList;
		
		map<Guest,Stage> guestBestTarget;
		
		bool getAllTargetStages <- false;
		bool getAttributes <- false;
		
		
		
		init{
			
				if(preferCrowd){
					color <- #red;
				}else{
					color <- #green;
				}
			
	
				if(isLeader){
					write '['+self+']: I am leader';
					stageCounter <- [stages[0]::0,stages[1]::0,stages[2]::0,stages[3]::0];
					crowdPreferenceList <-[guests[0]::false,guests[1]::false,guests[2]::false];
					pcrowdList <- [guests[0]::0.0,guests[1]::0.0,guests[2]::0.0];
					guestUtilityList <- [guests[0]::[stages[0]::0.0,stages[1]::0.0,stages[2]::0.0,stages[3]::0.0],
								 guests[1]::[stages[0]::0.0,stages[1]::0.0,stages[2]::0.0,stages[3]::0.0],
								 guests[2]::[stages[0]::0.0,stages[1]::0.0,stages[2]::0.0,stages[3]::0.0]];
		
					guestBestTarget <- [guests[0]::stages[0],guests[1]::stages[0],guests[2]::stages[0]];
					}
		
				
				plightShow <- rnd(0.0,10.0);
				pmusic <- rnd(0.0,10.0);
				pspeaker <- rnd(0.0,10.0);
				pband <- rnd(0.0,10.0);
				pvisual <- rnd(0.0,10.0);
				pdecoration <- rnd(0.0,10.0);
				
				//crowd mass is a deciding factor
				pcrowd <- 30.0;
				
				
//				write 'perferences of [' + self + ']: lightShow ' + plightShow + ', music ' + pmusic 
//				+ ', speaker ' + pspeaker + ', band ' + pband + ', visual ' + pvisual + ', decoration ' + pdecoration+ ', crowd ' + pcrowd;   
	
		
			}
		
		
		reflex calculatUtility when:!empty(cfps){
//			write 'I am going to reculate my utility';
			if(isLeader){
				getAllTargetStages <- false;
				getAttributes <- false;
				totalUtility <- 0.0;
			}
			
			list<message> msg <- cfps;
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
			}

					
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
			initTargetStage <- stages[pointer];
			hasFinalTarget <- false;
			finalTargetStage <- nil;
			write '[' + self + '] init target stage: ' + initTargetStage;	

		}
		
		//send attribute to leader
		reflex sendUtility when:!isLeader and !(empty(requests)) {
			
			do propose with: (message:requests[0], contents: [preferCrowd,pcrowd,utilityList]);
//			write 'send my utility to leader';
		}
		
		reflex receiveTargetStage when:!(empty(informs)) and !isLeader{
//			write 'receive best stratgy';
			message msg <- informs[0];
			list l <- msg.contents;			
			finalTargetStage <- map(l[0])[self];
			write  '['+ self + '] final target stage: ' + finalTargetStage;
			hasFinalTarget <- true;
			
		}
		
		reflex wander when:hasFinalTarget and finalTargetStage != nil and location distance_to finalTargetStage <= 10{
			
			do wander;
		}
		
		reflex gotoTargetStage when:hasFinalTarget and finalTargetStage != nil and location distance_to finalTargetStage > 10{
			do goto target:finalTargetStage;
		}
		
		
		
		
		//leader functions
		//asking for attributes from other guests
		reflex getAllTargetStage when:isLeader and !getAllTargetStages{
			
			ask Guest{
				if(self.initTargetStage != nil){
					myself.guestTargetList << self.initTargetStage;
				}
			}

			
			loop s over: guestTargetList{
				stageCounter[s] <- stageCounter[s] + 1;
			
//				write stageCounter;
			}			
			
			do start_conversation (to: guestsWithoutLeader, protocol: 'fipa-contract-net', performative: 'request', contents: ['ask for attributes']);
		
			getAllTargetStages <- true;
		}
		
		reflex receivesUtilities when:isLeader and !(empty(proposes)) and !getAttributes{
//			write 'receive guest proposes of utilities';
			
			
			loop p over:proposes{
					message msg <- p;
					list content <- list(msg.contents);
					
					//the leader knows the guests like crowd or not
					crowdPreferenceList[msg.sender] <- bool (content[0]);
					crowdPreferenceList[guests[2]] <- preferCrowd;
					
					//the leader knows how much the guests like crowd
					pcrowdList[msg.sender] <- float (content[1]);
					pcrowdList[guests[2]] <- pcrowd;

					list<float> uList <- content[2];
					
					//the initial utilities from the guests
					guestUtilityList[msg.sender] <- [stages[0]::uList[0],stages[1]::uList[1],stages[2]::uList[2],stages[3]::uList[3]];
					guestUtilityList[guests[2]] <- [stages[0]::utilityList[0],stages[1]::utilityList[1],stages[2]::utilityList[2],stages[3]::utilityList[3]];
//					write 'crowdPreferenceList: ' + crowdPreferenceList;
//					write 'prowdList: '+ pcrowdList;
//					write 'guest utility list:' + guestUtilityList;
				
			}
			write 'guest initial utility list:' + guestUtilityList;
			getAttributes <- true;
			
		}
		
		//calcualte global utility with crowd mass
		reflex calculateTotalUtility when: isLeader and totalUtility = 0.0 and getAttributes {
			int x<-0;
			int y<-0;
			int z<-0;
			
			
			float globalMaxUtility <- 0.0;
			
			//the leader consider all possible situations of which stage the guests go to 
			loop s1 over:stages{
				y<-0;
				z<-0;
				
				float tempUtility1 <- 0.0;
				tempUtility1<- tempUtility1 + guestUtilityList[guests[0]][s1];
				
				loop s2 over:stages{
					z<-0;
					
					float tempUtility2<-0;
					tempUtility2<- tempUtility1 + guestUtilityList[guests[1]][s2];
					
					loop s3 over:stages{					

						//original utility
						float tempUtility3<-0;
						tempUtility3<- tempUtility2 + guestUtilityList[guests[2]][s3];
						
						//calculate crowdmass
						if(crowdPreferenceList[guests[0]]){
							bool stageCrowd <- decideCrowdMass(s1,s2,s3);
							if(stageCrowd){
								tempUtility3 <- tempUtility3 + pcrowdList[guests[0]] * fcrowd;
							}else{
								tempUtility3 <- tempUtility3 - pcrowdList[guests[0]] * fcrowd;
							}
							
						}else{
							bool stageCrowd <- decideCrowdMass(s1,s2,s3);
							if(stageCrowd){
								tempUtility3 <- tempUtility3 - pcrowdList[guests[0]] * fcrowd;
							}else{
								tempUtility3 <- tempUtility3 + pcrowdList[guests[0]] * fcrowd;
							}
						}
						
						if(crowdPreferenceList[guests[1]]){
							bool stageCrowd <- decideCrowdMass(s2,s1,s3);
							if(stageCrowd){
								tempUtility3 <- tempUtility3 + pcrowdList[guests[1]] * fcrowd;
							}else{
								tempUtility3 <- tempUtility3 - pcrowdList[guests[1]] * fcrowd;
							}
						}else{
							bool stageCrowd <- decideCrowdMass(s2,s1,s3);
							if(stageCrowd){
								tempUtility3 <- tempUtility3 - pcrowdList[guests[1]] * fcrowd;
							}else{
								tempUtility3 <- tempUtility3 + pcrowdList[guests[1]] * fcrowd;
							}
						}						
						
						if(crowdPreferenceList[guests[2]]){
							bool stageCrowd <- decideCrowdMass(s3,s1,s2);
							if(stageCrowd){
								tempUtility3 <- tempUtility3 + pcrowdList[guests[2]] * fcrowd;
							}else{
								tempUtility3 <- tempUtility3 - pcrowdList[guests[2]] * fcrowd;
							}
						}else{
							bool stageCrowd <- decideCrowdMass(s3,s1,s2);
							if(stageCrowd){
								tempUtility3 <- tempUtility3 - pcrowdList[guests[2]] * fcrowd;
							}else{
								tempUtility3 <- tempUtility3 + pcrowdList[guests[2]] * fcrowd;
							}
						}
						
//						write tempUtility;
						if(tempUtility3 > globalMaxUtility){
							globalMaxUtility <- tempUtility3;
							guestBestTarget[guests[0]] <- s1;
							guestBestTarget[guests[1]] <- s2;
							guestBestTarget[guests[2]] <- s3;
						}
						
						z <- z+1;
					}
					y <- y+1;
				}
				
				x <- x+1;
			}
			
			write 'global max utility: '+ globalMaxUtility;
			write 'guest best target stages: '+ guestBestTarget;
			
			do start_conversation (to: guestsWithoutLeader , protocol: 'fipa-contract-net', performative: 'inform', contents: [guestBestTarget]);
//			write 'leader send best stratgy';
			
			
			self.finalTargetStage <- guestBestTarget[guests[2]];
			self.hasFinalTarget <- true;
			write  '['+ self + '] final target stage: ' + finalTargetStage;
			
			
			
		}
		
		//an action
		bool decideCrowdMass(Stage s1,Stage s2,Stage s3){
			int counter <- 1;
			if(s1 = s2){
				counter <- counter + 1;	
			}
			if(s1=s3){
				counter <- counter + 1;	
			}
			
			if(counter >= 2){
				return true;
			}else{
				return false;
			}
			
			
		}
		
		aspect base{
			draw sphere(2) color: color;
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
	


