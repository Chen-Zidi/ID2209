/**
* Name: ProjectModel
* Based on the internal empty template. 
* Author: Zidi Chen, Sihan Chen
* 
* 
* People come to festival
* 
* personal traits: generous, didactic, aggressive
* 
* stage: bar, game discussion corner, film, stadium
* 
* People type: chill, party, bad children, PUBG lover, Fortnite lover
* 
* conflict: 
* 
* bar : chill - party : generous(party)
* film : bad children - chill : didactic(chill)
* game discussion corner: PUBG lover - Fortnite lover : aggressive(both)
* 
* other rule:
* stadium somtimes hold a contest: the contest might be game contest or sport contest
* guest decides to go to the stadium when there is contest(game lover tends to go to watch game contest)
* 
* trace the happiness of guests and satisfcation of stages
*  
* 
*/


model ProjectModel

global{

	int themeCounter <- 0;
	float chill_people_happiness <- 100.0;
	float party_people_happiness <- 100.0;
	float bad_children_happiness <- 100.0;
	float PUBG_lover_happiness <- 100.0;
	float Fortnite_lover_happiness <- 100.0;
	float bar_satisfaction <- 100.0;
	float game_corner_satisfaction <- 100.0;
	float film_satisfaction <- 100.0;
	float stadium_satisfaction <- 100.0;
	list<Guest> guestList;
	list<Stage> stageList;
	list<Guest> PUBGLoverList;
	list<Guest> FortniteLoverList;
	Counter counter;
	
	list<string> themeList <- ['bar','game discussion corner','film','stadium'];
	
	
	list<string> guestTypeList <- ['chill', 'party', 'bad children', 'PUBG lover', 'Fortnite lover'];
	init{
		
		//create stages
		create Stage number: 1{
			location <- {25,25};
			position <- {25,25};
			stageList << self;
		}
		
		create Stage number: 1{
			location <- {25,75};
			position <- {25,75};
			stageList << self;
		}
		
		create Stage number: 1{
			location <- {75,25};
			position <- {75,25};
			stageList << self;
		}
		
		create Stage number: 1{
			location <- {75,75};
			position <- {75,75};
			stageList << self;
		}
		
		 create Counter number:1{
		 	counter <- self;	
		 }
		
		//create guests
		//each type 10 guests
		loop t over:guestTypeList{
				create Guest number:10{
				self.type <- t;
				
				if(t = 'PUBG lover'){
					PUBGLoverList << self;
				}
				
				if(t = 'Fortnite lover'){
					FortniteLoverList << self;
				}
				
				guestList << self;
				if(t = 'chill'){
					self.color <- #red;
				}else if(t = 'party'){
					self.color <- #yellow;
				}else if(t = 'bad children'){
					self.color <- #black;
				}else if(t = 'PUBG lover'){
					self.color <- #green;
				}else if(t = 'Fortnite lover'){
					self.color <- #purple;
				}
				
				
//				write '[' + self + ']' + ' my type is : ' + self.type;
			}
		}
		
	}
	
}

//guest species
species Guest skills:[moving, fipa]{
	//three traits
	float generous;
	float didactic;
	float aggressive;
	
	int timer <- 0 update: timer + 1;
	
//	bool gameLoverAnnoyed <- false;

	string type <- nil;
	Stage targetStage <- nil;
	
	
	rgb color;
	
	map<string,Stage> stages <- [themeList[0]::stageList[0],themeList[1]::stageList[0],themeList[2]::stageList[0],themeList[3]::stageList[0]];
	
	init{
		generous <- rnd(0,1.0);
		didactic <- rnd(0,1.0);
		aggressive <- rnd(0,1.0);
		
		ask Stage{
			myself.stages[self.theme] <- self;
		}
		
	}
	
	//when not in the stadium and after 150 time, the guest update the target
	reflex updateTargetStage when:((timer mod 150 ) = 0 or timer = 1) and targetStage != stageList[3]{
		do updateTarget;
	}
	
	//update color
	string updateColor{
		if(type = 'chill'){
			self.color <- #red;
		}else if(type = 'party'){
			self.color <- #yellow;
		}else if(type = 'bad children'){
			self.color <- #black;
		}else if(type = 'PUBG lover'){
			self.color <- #green;
		}else if(type = 'Fortnite lover'){
			self.color <- #purple;
		}
		return 'ok';
	}
	
	//the guests change target stage at certain time
	string updateTarget{
	
		//decide to goto stage or just wander
		bool gotoStage <- flip(0.8);
		
		//update color
		do updateColor;
		
		//decide the target
		if(gotoStage){
			targetStage <- stageList[rnd(0,length(stageList)-2)];//not include stadium
		}else{
			targetStage <- nil;
		}
		
		
		//calculate the stage satisfcation 
		if(targetStage != nil){
		if(targetStage.theme = 'film'){
			film_satisfaction <- film_satisfaction + rnd(1.0,2.0);
		}else if(targetStage.theme = 'game discussion corner'){
			game_corner_satisfaction <- game_corner_satisfaction + rnd(1.0,2.0);
		}else if(targetStage.theme = 'bar'){
			bar_satisfaction <- bar_satisfaction + rnd(1.0,2.0);
		}
			
		}
		
		//calculate happiness
		if(type='chill'){
			chill_people_happiness <- chill_people_happiness + rnd(1.0,2.0);
		}else if(type = 'party'){
			party_people_happiness <- party_people_happiness + rnd(1.0,2.0);
		}else if(type='bad children'){
			bad_children_happiness <- bad_children_happiness + rnd(1.0,2.0);
		}else if(type='PUBG lover'){
			PUBG_lover_happiness <- PUBG_lover_happiness + rnd(1.0,2.0);
		}else if(type='Fortnite lover'){
			Fortnite_lover_happiness <- Fortnite_lover_happiness + rnd(1.0,2.0);
		}
		
		return 'ok';
	}
	
	
	//when party people drink in bar, he/she broadcasts.
	reflex partyPeopleInBar when:type='party' and location distance_to stages['bar'] <= 10 and targetStage!= nil and targetStage.theme='bar'{
		do start_conversation (to: guestList , protocol: 'no-protocol', performative: 'inform', contents: ['party','bar',generous]);
		
	}
	
	//when bad children watch a film, he/she broadcasts.
	reflex badChildrenInFilm when:type='bad children'  and location distance_to stages['film'] <= 10 and targetStage!= nil and targetStage.theme = 'film'{
		do start_conversation (to: guestList , protocol: 'fipa-contract-net', performative: 'cfp', contents: ['bad children','film']);
		
	}
	
	//when PUBG lover is in the game discussion corner, he/she broadcasts.
	reflex PUBGLoverInGameCorner when:type = 'PUBG lover' and targetStage!= nil and targetStage.theme = 'game discussion corner' and location distance_to stages['game discussion corner'] <= 10{
		do start_conversation (to: FortniteLoverList , protocol: 'fipa-contract-net', performative: 'propose', contents: ['PUBG lover','game discussion corner',aggressive]);
		
	}		


	//PUBG lover has a fight with Fortnite lover in the game discussion corner 
	reflex PUBGLoverLeaveGameCorner when:type='PUBG lover' and !(empty(accept_proposals)) and location distance_to stages['game discussion corner'] <= 10 and targetStage!= nil and targetStage.theme = 'game discussion corner'{
		//minus happiness and satisfaction
		PUBG_lover_happiness <- PUBG_lover_happiness - rnd(5.0,6.0);
		game_corner_satisfaction <- game_corner_satisfaction - rnd(5.0,6.0);

//		write 'It is me ' + targetStage;
		bool annoyed <- false;
		
		list<message> msg <- accept_proposals;
		loop m over:msg{
			list content <- list(m.contents);
			string c <- string(content[0]);
			if(c='leave'){
				ask Guest{
					if(self = m.sender){
						//make sure the message sender is in the game discussion corner
						if(location distance_to(stages['game discussion corner']) <=  10 and self.targetStage != nil and self.targetStage.theme = 'game discussion corner'){
							annoyed <- true;
//							write '['+ myself + ', ' + myself.type + ']' + self;
						}
						
					}
				}
				
				
			}
		}
	
		if(annoyed){
			color <- #blue;

			//go to another stage(not game discussion corner)
			list<Stage> newTargetList;
			ask Stage{
				if(self.theme != 'game discussion corner' and self.theme != 'stadium'){
					newTargetList << self;
				}
			}
			
			write '['+ self + ', ' + self.type + ']' + ':{leave} fight with Fortnite lover at game discussion corner';
				
			targetStage <- newTargetList[rnd(0,length(newTargetList)- 1)];
			
			
		}
		
			
	}
	
	
	//Fortnite lover is in game discussion corner and receives broadcast from PUBG lover
	reflex FortniteLoverLeave when:type = 'Fortnite lover' and !(empty(proposes)) and location distance_to stages['game discussion corner'] <= 10 and targetStage!= nil and targetStage.theme = 'game discussion corner'{
		bool annoyed <- false;
		list<message> msg <- proposes;
		loop m over:msg{
			list content <- list(m.contents);
			string peopleType <- string(content[0]);
			string place <- string(content[1]);
			float ag <- float(content[2]);
			
			
			
			//if the PUBG lover and myself are both aggressive enough, we fight in the game discussion corner
			if(peopleType = 'PUBG lover' and place = 'game discussion corner' and ag >= 0.7 and self.aggressive >= 0.7){
				ask Guest{
					if(self = m.sender){
					//check if the sender is at the game discussion corner
						if(location distance_to stages['game discussion corner'] <= 10 and self.targetStage != nil and self.targetStage.theme = 'game discussion corner'){
							
							annoyed <- true;//I am annoyed
							do accept_proposal with:(message:m, contents: ['leave']);
//							self.gameLoverAnnoyed <- true;
//							write '['+ myself + ', ' + myself.type + ']' + m.sender;	
						}
								
					}
				}
					
			}
		
			
	
		}
		
		//if we have fight
		if(annoyed){
			//minus happiness and satisfaction
			Fortnite_lover_happiness <- Fortnite_lover_happiness - rnd(5.0,6.0);
			game_corner_satisfaction <- game_corner_satisfaction - rnd(5.0,6.0);
			
			//change color
			color <- #blue;
			//go to new stage
			list<Stage> newTargetList;
			ask Stage{
				if(self.theme != 'game discussion corner' and self.theme != 'stadium'){
					newTargetList << self;
				}
			}
			
			write '['+ self + ', ' + self.type + ']' + ':{leave} fight with PUBG lover at game discussion corner';
				
			
			targetStage <- newTargetList[rnd(0,length(newTargetList)-1)];
			
		}		
	}
	
	
	//chill people receive broadcast from bad children in the film
	reflex cillPeopleInFilm when:type = 'chill' and location distance_to stages['film'] <= 10 and !(empty(cfps)) and targetStage!= nil and targetStage.theme = 'film'{
		bool annoyed <- false;
		list<message> msg <- cfps;
		loop m over:msg{
			list content <- list(m.contents);
			string peopleType <- string(content[0]);
			string place <- string(content[1]);
			
			//if chill people meets bad children in film and chill people is not didactic enough
			//feel annoyed
			if(peopleType = 'bad children' and place = 'film' and didactic < 0.7){
				
				ask Guest{
					if(self = m.sender){
						if(location distance_to stages['film'] <= 10 and self.targetStage != nil and self.targetStage.theme = 'film'){	
							annoyed <- true;
						}			
					}
								
				}
				
				
			}else if(peopleType = 'bad children' and place = 'film' and didactic >= 0.7){		
//					write '['+ self + ', ' + self.type + ']' + ':{stay} educate bad children at film';
			}
			
			
		}
		
		//If I an annoyed
		if(annoyed){
			//minus happiness and satisfaction
			chill_people_happiness <- chill_people_happiness - rnd(5.0,6.0);
			film_satisfaction <- film_satisfaction - rnd(5.0,6.0);
			color <- #blue;
			list<Stage> newTargetList;//go to new stage
			ask Stage{
				if(self.theme != 'film' and self.theme != 'stadium'){
					newTargetList << self;
				}
			}
			
				write '['+ self + ', ' + self.type + ']' + ':{leave} annoyed by bad children at film';
				
			
			targetStage <- newTargetList[rnd(0,length(newTargetList)-1)];
			
		}		
	}

	//chill people is in bar and receives broadcast from party people
	reflex chillPeopleInBar when:type = 'chill' and location distance_to stages['bar'] <= 10 and !(empty(informs)) and targetStage!= nil and targetStage.theme = 'bar'{
		bool annoyed <- false;
		list<message> msg <- informs;
		loop m over:msg{
			list content <- list(m.contents);
			string peopleType <- string(content[0]);
			string place <- string(content[1]);
			float generousFactor <- float(content[2]);
			
			//if chill people meet party people in bar 
			//and party people is not generous enough to buy a drink for chill people
			//then chill people will be annoyed and leave
			if(peopleType = 'party' and place = 'bar' and generousFactor < 0.7){
				ask Guest{
					if(self = m.sender){
						if(location distance_to stages['bar'] <= 10 and self.targetStage != nil and self.targetStage.theme = 'bar'){	
							annoyed <- true;
						}			
					}
								
				}
			}else if(peopleType = 'party' and place = 'bar' and generousFactor >= 0.7){
//				write '['+ self + ', ' + self.type + ']' + ':{stay} have a drink from party people in bar';
			}
			
			
		}
		
		//if chill people is annoyed
		if(annoyed){
			//minus happiness and satisfaction
			chill_people_happiness <- chill_people_happiness - rnd(5.0,6.0);
			bar_satisfaction <- bar_satisfaction - rnd(5.0,6.0);
			color <- #blue;
			list<Stage> newTargetList;//go to new stage
			ask Stage{
				if(self.theme != 'bar' and self.theme != 'stadium'){
					newTargetList << self;
				}
			}
			
				write '['+ self + ', ' + self.type + ']' + ':{leave} annoyed by party people in bar.';
				
			targetStage <- newTargetList[rnd(0,length(newTargetList)-1)];
			
		}		
		
	}
	
	//receive info that stadium holds a contest 
	reflex receiveContestInfo when: !(empty(requests)){
		message msg <- requests[0];
		list content <- list(msg.contents);
		string place <- string(content[0]);
		string contest <- string(content[1]);// contest type
		string status <- string(content[2]);
		
		if(status = 'begin'){
			bool gotoStadium;
		
			if(contest = 'game contest'){
				if(type = 'PUBG lover' or type = 'Fortnite lover'){
					gotoStadium <- flip(0.8);//game lover is highly possible to go to game contest
 				}else{
 					gotoStadium <- flip(0.3);
 				}
			}else if(contest = 'sport contest'){
				gotoStadium <- flip(0.3);
			}
			
			
			if(gotoStadium){//go to staidum
				targetStage <- stageList[3];
				stadium_satisfaction <- stadium_satisfaction + rnd(1.0,2.0);//plus stage satisfaction
				if((type = 'PUBG lover' or type = 'Fortnite lover') and contest ='game contest'){
					//if game lover go to game contest, they are more satisfied with the stage
					stadium_satisfaction <- stadium_satisfaction + rnd(3.0,4.0);
				}
			
		
			}	
		
		}else if (status = 'end'){//receive the contest is going to end
			if(targetStage = stageList[3]){//guests who are at the stadium
				do updateTarget;//update target
			}
		}
	
	}
	

	//when the guest does not want to any stage
	//the guest just wander at one random point
	reflex wanderWithoutTarget when:targetStage = nil{
		do goto target:{rnd(0,100),rnd(0,100)};
		do wander;
	}

	//the guest arrive at one stage
	reflex arriveStage when:targetStage != nil and location distance_to targetStage <= 10{
		do updateColor;
		do wander;
//		write '['+ self + ', ' + self.type +  ']' + ': I am at ' + targetStage.theme + '.';
	}
		
	//go to target stage	
	reflex gotoTargetStage when:targetStage != nil and location distance_to targetStage > 10{
		do goto target:targetStage;
	}


	aspect base{
			draw sphere(1) color: color;
		}	
}

//stage
species Stage skills:[fipa] {
	rgb color <- #orange;
	string theme;
	point position;
	
	//for staidum
	bool beginNewContest <- false;
	int beginTime <- 0;
	int endTime <- 0;
	string type;//contest type if stage is a stadium
	
	int timer <- 0 update: time + 1;
	
	init{
		theme <- themeList[themeCounter];
		themeCounter <- themeCounter + 1;
		
		
		write '[' + self + ']' + ' my theme is : ' + theme;
	}
	
	//stadium will sometimes hold game contest/sport contest 
	reflex beginStadiumContest when: theme = 'stadium' and ((timer mod 250) = 0 or timer = 1) and !beginNewContest{
		beginTime <- timer;
		
		//decide to hold a context or not
		bool holdContest <- flip(0.7);
		
		if(holdContest){
			
			bool gameC <- flip(0.5);
			if(gameC){
				type <- 'game contest';
			}else{
				type <- 'sport contest';
			}
			
			write '[' + self + ']' + ' : stadium holds ' + type ; 
			//broadcast contest starting
			do start_conversation (to: guestList , protocol: 'fipa-contract-net', performative: 'request', contents: ['stadium', type, 'begin']);
			
			//set desired end time
			endTime <- beginTime + 100;
			beginNewContest <- true;
		}
		
		
	}
	
	//end contest at desired time
	reflex endStadiumContest when:theme = 'stadium' and beginNewContest and (timer = endTime) {
		beginNewContest <- false;
		write '[' + self + ']' + ' : stadium ends ' + type ; 
		//broadcast contest end
		do start_conversation (to: guestList , protocol: 'fipa-contract-net', performative: 'request', contents: ['stadium', type ,'end']);
	}
	
	aspect base{
			draw circle(10) color: color;
		}
}

//for calculating change percentage of the happiness
	species Counter{
		int timer <- 0 update:timer+1;
		float old_chill_people_happiness;
		float old_party_people_happiness;
		float old_bad_children_happiness;
		float old_PUBG_lover_happiness;
		float old_Fortnite_lover_happiness;
		
		
		float per_chill <- 0.0;
		float per_party <- 0.0;
		float per_bad <- 0.0;
		float per_PUBG <- 0.0;
		float per_Fortnite <- 0.0;
		
		init{
			//old happiness is the initial happiness value(100)
			old_chill_people_happiness <- chill_people_happiness;
			old_party_people_happiness <- party_people_happiness;
			old_bad_children_happiness <- bad_children_happiness;
			old_PUBG_lover_happiness <- PUBG_lover_happiness;
			old_Fortnite_lover_happiness <- Fortnite_lover_happiness;
			
			
		}
		
		//calculate percentage every 300 time
		reflex calculatePercentage when:(timer mod 300) = 0{
			per_chill <- (chill_people_happiness - old_chill_people_happiness)/old_chill_people_happiness;
			per_party <- (party_people_happiness - old_party_people_happiness)/old_party_people_happiness;
			per_bad <- (bad_children_happiness - old_bad_children_happiness)/old_bad_children_happiness;
			per_PUBG <- (PUBG_lover_happiness - old_PUBG_lover_happiness)/old_PUBG_lover_happiness;
			per_Fortnite <- (Fortnite_lover_happiness - old_Fortnite_lover_happiness)/old_Fortnite_lover_happiness;
			

			
			
		} 
		
		
		
	}




experiment main type:gui{
	output{
		display map type:opengl{
			
			species Guest aspect:base;
			species Stage aspect:base;
		}
		
    
    display "stage satisfaction" refresh: every(1#cycles) {
        chart "Satisfaction of stages" type: series style: spline {
        	data "bar" value: bar_satisfaction color: #green;
        	data "game discussion corner" value: game_corner_satisfaction color: #red;
        	data "film" value: film_satisfaction color: #yellow;
        	data "stadium" value: stadium_satisfaction color: #black;
        	
        
        }
    }
    
    
    display "guest happiness" {
        chart "guest happiness" type: scatter {
        data "cill people" value: (chill_people_happiness) accumulate_values: true line_visible:true ;
        data "party people" value: (party_people_happiness) accumulate_values: true line_visible:true ;
        data "bad children" value: (bad_children_happiness) accumulate_values: true line_visible:true ;
        data "PUBG lover" value: (PUBG_lover_happiness) accumulate_values: true line_visible:true ;
        data "Fortnite lover" value: (Fortnite_lover_happiness) accumulate_values: true line_visible:true ;
        
        }
    }      
    
    
    
     display "change percentage of guest happiness" {
        chart "change percentage of guest happiness" type: histogram {
 
			datalist ["chill","party","bad children","PUBG lover","Fortnite lover"]
			value:[counter.per_chill,counter.per_party,counter.per_bad,counter.per_PUBG,counter.per_Fortnite];
		    
        }
    }
    
	}
	
}
