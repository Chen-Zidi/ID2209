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
* place: bar, game discussion corner, film, band
* 
* People type: chill, party, bad children, PUBG lover, Fortnite lover
* 
* conflict: 
* 
* bar : chill - party : generous(party)
* film : bad children - chill : didactic(chill)
* game discussion corner: PUBG lover - Fortnite lover : aggressive(both)
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
	float band_satisfaction <- 100.0;
	list<Guest> guestList;
	list<Stage> stageList;
	list<string> themeList <- ['bar','game discussion corner','film','band'];
	list<string> guestTypeList <- ['chill', 'party', 'bad children', 'PUBG lover', 'Fortnite lover'];
	init{
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
		
		loop t over:guestTypeList{
				create Guest number:10{
				self.type <- t;
				guestList << self;
				
//				write '[' + self + ']' + ' my type is : ' + self.type;
			}
		}
		
		
	}
	
}

species Guest skills:[moving, fipa]{
	float generous;
	float didactic;
	float aggressive;
	
	int timer <- 0 update: timer + 1;
	
	float happiness <- 10.0;

	string type <- nil;
	
	Stage targetStage <- nil;
	
	
	rgb color <- #yellow;
	
	map<string,Stage> stages <- [themeList[0]::stageList[0],themeList[1]::stageList[0],themeList[2]::stageList[0],themeList[3]::stageList[0]];
	
	init{
		generous <- rnd(0,1.0);
		didactic <- rnd(0,1.0);
		aggressive <- rnd(0,1.0);
		
		ask Stage{
			myself.stages[self.theme] <- self;
		}
		
//		write stages;
	}
	
	//the guests change target stage at certain time
	reflex updateTarget when:(timer mod 100) = 0 or timer = 1{
		
//		bool gotoStage <- flip(0.6);
		color <- #yellow;
		
//		if(gotoStage){
			targetStage <- stageList[rnd(0,length(stageList)-1)];
//		}
		
		if(targetStage.theme = 'film'){
			film_satisfaction <- film_satisfaction + 1.0;
			
		}else if(targetStage.theme = 'game discussion corner'){
			game_corner_satisfaction <- game_corner_satisfaction + 1.0;
		}else if(targetStage.theme = 'bar'){
			bar_satisfaction <- bar_satisfaction + 1.0;
		}else if(targetStage.theme = 'band'){
			band_satisfaction <- band_satisfaction + 1.0;
		}
	}
	
	

	reflex partyPeopleInBar when:type='party' and location distance_to stages['bar'] <= 10 and targetStage.theme='bar'{
		
		do start_conversation (to: guestList , protocol: 'no-protocol', performative: 'inform', contents: ['party','bar',generous]);
		
		
	}
	
	reflex badChildrenInFilm when:type='bad children' and location distance_to stages['film'] <= 10 and targetStage.theme = 'film'{
		
		do start_conversation (to: guestList , protocol: 'fipa-contract-net', performative: 'cfp', contents: ['bad children','film']);
		
	}
	
	reflex PUBGLoverInGameCorner when:type='PUBG lover' and location distance_to stages['game discussion corner'] <= 10 and targetStage.theme = 'game discussion corner'{
		
		do start_conversation (to: guestList , protocol: 'fipa-contract-net', performative: 'propose', contents: ['PUBG lover','game discussion corner',aggressive]);
		
	}
	
	
	reflex PUBGLoverLeaveGameCorner when:type='PUBG lover' and location distance_to stages['game discussion corner'] <= 10 and targetStage.theme = 'game discussion corner' and !(empty(queries)){
		happiness <- happiness - 1.0;
		
		PUBG_lover_happiness <- PUBG_lover_happiness - 1.0;
		game_corner_satisfaction <- game_corner_satisfaction - 2.0;
		
		color <- #red;
			list<Stage> newTargetList;
			ask Stage{
				if(self.theme != 'game discussion corner'){
					newTargetList << self;
				}
			}
			
				write '['+ self + ', ' + self.type + ']' + ': I am annoyed by Fortnite lover at game discussion corner.';
				
			
			targetStage <- newTargetList[rnd(0,length(newTargetList)-1)];
	}
	
	reflex FortniteLoverInGameCorner when:type = 'Fortnite lover' and location distance_to stages['game discussion corner'] <= 10 and !(empty(proposes)) and targetStage.theme = 'game discussion corner'{
		bool annoyed <- false;
		list<message> msg <- proposes;
		loop m over:msg{
			list content <- list(m.contents);
			string peopleType <- string(content[0]);
			string place <- string(content[1]);
			float ag <- float(content[2]);
			if(peopleType = 'PUBG lover' and place = 'game discussion corner' and ag >= 0.7 and self.aggressive >= 0.7){
				annoyed <- true;
				do query with: (message:m, contents: ['leave']);
			}else{
					write '['+ self + ', ' + self.type + ']' + ': I meet PUBG lover and game discussion corner. We do not have fight and stay together.';
			}
			
			
		}
		
		if(annoyed){
			happiness <- happiness - 1.0;
			Fortnite_lover_happiness <- Fortnite_lover_happiness - 1.0;
			game_corner_satisfaction <- game_corner_satisfaction - 2.0;
			
			color <- #red;
			list<Stage> newTargetList;
			ask Stage{
				if(self.theme != 'game discussion corner'){
					newTargetList << self;
				}
			}
			
				write '['+ self + ', ' + self.type + ']' + ': I am annoyed by PUBG lover at game discussion corner.';
				
			
			targetStage <- newTargetList[rnd(0,length(newTargetList)-1)];
			
		}		
	}
	
	
	
	reflex cillPeopleInFilm when:type = 'chill' and location distance_to stages['film'] <= 10 and !(empty(cfps)) and targetStage.theme = 'film'{
		bool annoyed <- false;
		list<message> msg <- cfps;
		loop m over:msg{
			list content <- list(m.contents);
			string peopleType <- string(content[0]);
			string place <- string(content[1]);
			
			if(peopleType = 'bad children' and place = 'film' and didactic < 0.7){
				annoyed <- true;
			}else if(peopleType = 'bad children' and place = 'film' and didactic >= 0.7){
				
					write '['+ self + ', ' + self.type + ']' + ': I meet bad children at film. I will stay and I will educate the bad children.';
					
				
				
			}
			
			
		}
		
		if(annoyed){
			happiness <- happiness - 1.0;
			chill_people_happiness <- chill_people_happiness - 1.0;
			film_satisfaction <- film_satisfaction - 2.0;
			color <- #red;
			list<Stage> newTargetList;
			ask Stage{
				if(self.theme != 'film'){
					newTargetList << self;
				}
			}
			
				write '['+ self + ', ' + self.type + ']' + ': I am annoyed by bad children at film.';
				
			
			targetStage <- newTargetList[rnd(0,length(newTargetList)-1)];
			
		}		
	}

	reflex chillPeopleInBar when:type = 'chill' and location distance_to stages['bar'] <= 10 and !(empty(informs)) and targetStage.theme = 'bar'{
		bool annoyed <- false;
		list<message> msg <- informs;
		loop m over:msg{
			list content <- list(m.contents);
			string peopleType <- string(content[0]);
			string place <- string(content[1]);
			float generousFactor <- float(content[2]);
			
			if(peopleType = 'party' and place = 'bar' and generousFactor < 0.7){
				annoyed <- true;
			}else if(peopleType = 'party' and place = 'bar' and generousFactor >= 0.7){
				
					write '['+ self + ', ' + self.type + ']' + ': I meet party people in bar. I will stay for his generousity';
					
				
			}
			
			
		}
		
		if(annoyed){
			happiness <- happiness - 1.0;
			chill_people_happiness <- chill_people_happiness - 1.0;
			bar_satisfaction <- bar_satisfaction - 2.0;
			color <- #red;
			list<Stage> newTargetList;
			ask Stage{
				if(self.theme != 'bar'){
					newTargetList << self;
				}
			}
			
				write '['+ self + ', ' + self.type + ']' + ': I am annoyed by party people in bar.';
				
			targetStage <- newTargetList[rnd(0,length(newTargetList)-1)];
			
		}		
		
	}

	reflex wanderWithoutTarget when:targetStage = nil{
		do wander;
	}

	reflex wander when:targetStage != nil and location distance_to targetStage <= 10{
		do wander;
//		write '['+ self + ', ' + self.type +  ']' + ': I am at ' + targetStage.theme + '.';
	}
		
	reflex gotoTargetStage when:targetStage != nil and location distance_to targetStage > 10{
		do goto target:targetStage;
	}


	aspect base{
			draw sphere(2) color: color;
		}	
}


species Stage {
	rgb color;
	string theme;
	point position;
	
	init{
		theme <- themeList[themeCounter];
		themeCounter <- themeCounter + 1;
		if(theme = 'bar'){
			color <- #blue;
		}else if(theme = 'game discussion corner'){
			color <- #green;
		}else if(theme = 'film'){
			color <- #pink;
		}else if(theme = 'band'){
			color <- #purple;
		}else{
			color <- #black;
			
		}
		
		write '[' + self + ']' + ' my theme is : ' + theme;
	}
	
	
	aspect base{
			draw circle(10) color: color;
		}
}

experiment main type:gui{
	output{
		display map type:opengl{
			
			species Guest aspect:base;
			species Stage aspect:base;
		}
		
		display chart refresh: every(1#cycles) {
        chart "Happiness of guests" type: series style: spline {
        	data "chill people" value: chill_people_happiness color: #green;
        	data "party people" value: party_people_happiness color: #red;
        	data "bad children" value: bad_children_happiness color: #yellow;
        	data "PUBG lover" value: PUBG_lover_happiness color: #black;
        	data "Fortnite lover" value: Fortnite_lover_happiness color: #grey;
        }
    }
    
//    display chart refresh: every(1#cycles) {
//        chart "Satisfication of stages" type: series style: spline {
//        	data "bar" value: bar_satisfaction color: #green;
//        	data "game discussion corner" value: game_corner_satisfaction color: #red;
//        	data "film" value: film_satisfaction color: #yellow;
//        	data "band" value: band_satisfaction color: #black;
//        	
//        
//        }
//    }
    
    
//    display "my_display" {
//        chart "guest happiness" type: scatter {
//        data "cill people" value: (chill_people_happiness) accumulate_values: true line_visible:true ;
//        data "party people" value: (party_people_happiness) accumulate_values: true line_visible:true ;
//        data "bad children" value: (bad_children_happiness) accumulate_values: true line_visible:true ;
//         data "PUBG lover" value: (PUBG_lover_happiness) accumulate_values: true line_visible:true ;
//         data "Fortnite lover" value: (Fortnite_lover_happiness) accumulate_values: true line_visible:true ;
//        
//        }
//    }      
    
	}
	
}
