/**
* Name: FestivalBdi
* Based on the internal empty template. 
* Author: Spycsh
* Tags: 
*/


model FestivalBdi

/* Insert your model definition here */
global{
	// get by name
	string activity_at_location <- "activity_at_location";
	predicate activity_location <- new_predicate(activity_at_location);
	
	predicate find_activities <- new_predicate("find activities");
	predicate choose_activity <- new_predicate("choose activity");
	predicate attend_activity <- new_predicate("attend activities");
	
	predicate change_place <- new_predicate("change place");
	
	predicate leave_place <- new_predicate("leave place");
		
	predicate join_contest<- new_predicate("join_contest");
	predicate leave_contest <- new_predicate("leave contest");
	
	list<string> guestTypeList <- ['chill', 'party', 'bad children', 'PUBG lover', 'Fortnite lover'];
	
	list<Guest> guestList;
	list<Stage> stageList;
	
	float bar_satisfaction <- 100.0;
	float game_corner_satisfaction <- 100.0;
	float film_satisfaction <- 100.0;
	float stadium_satisfaction <- 100.0;
	
	
	init{		
		// create guests
		create Guest number:10{
			self.type <- 'chill';
			self.color <- #red;
			guestList << self;
		}	
		create Guest number:10{
			self.type <- 'party';
			self.color <- #yellow;
			guestList << self;
		}
		create Guest number:10{
			self.type <- 'bad children';
			self.color <- #black;
			guestList << self;
		}

		create Guest number:10{
			self.type <- 'PUBG lover';
			self.color <- #green;
			guestList << self;
		}
		create Guest number:10{
			self.type <- 'Fortnite lover';
			self.color <- #purple;
			guestList << self;
		}
		
		// create Stage
		create Stage number: 1{
			location <- {25,25};
			position <- {25,25};
			theme <- "bar";
			stageList << self;
		}
		
		create Stage number: 1{
			location <- {25,75};
			position <- {25,75};
			theme <- "game discussion corner";
			stageList << self;			
		}
		
		create Stage number: 1{
			location <- {75,25};
			position <- {75,25};
			theme <- "film";
			stageList << self;	
		}
		
		create Stage number: 1{
			location <- {75,75};
			position <- {75,75};
			theme <- "stadium";
			stageList << self;	
		}
		
		
	}
}

species Guest skills:[moving, fipa] control: simple_bdi{
	float generous;
	float didactic;
	float aggressive;
	
	float view_dist<-30;
	
	int timer <- 0 update: timer + 1;
	Stage targetStage<-nil;
	
	string currentTheme;
	
	rgb color;
	
	string type <- nil;
	
	point target;
	
	
	init{
		generous <- rnd(0,1.0);
		didactic <- rnd(0,1.0);
		aggressive <- rnd(0,1.0);
		
		// default desire is to find some activities 
		do add_desire(find_activities);
		
	}
	
	// find a stage in some distance
	// then remove the intention of finding activities
	perceive target: Stage in: view_dist {
		focus id:activity_at_location var:location;		// location of the stage 
        ask myself {
            do remove_intention(find_activities, false);
        }
    }
	
	// rules
	// if activity location has been found, then get a new desire
	rule belief: activity_location new_desire: attend_activity strength: 2.0;
	
	// conflict => leave place
	// if not compatible with others, then leave
	plan leave_place intention: leave_place{
		self.color <- #blue;

		point new_target_leave;
		// the conflict should only be held in film, bar and game discussion corner
		if(currentTheme="film"){
			new_target_leave <- {25, 25};  // go to bar
		}else if(currentTheme="bar"){
			new_target_leave <- {25, 75};   // go to game corner
		}else if(currentTheme="game discussion corner"){
			new_target_leave <- {75, 25};	 // go to film
		}else{
			new_target_leave <- {75, 75};
		}
		
		
		if(new_target_leave distance_to location<=5){
			target <- new_target_leave;
			//		do decreaseSatisfaction(currentTheme);
			// update the stage satisfaction
			do decreaseSatisfaction(currentTheme);
			do increaseSatisfaction(getThemeByPosition(target));
			
			// already leave the original place, remove the desire
			do remove_desire(leave_place);

			currentTheme <- getThemeByPosition(new_target_leave);
			do wander;
			//update color
			do updateColor(type);

		}else{
//			write "timer"+timer+"[leave]currentTheme: "+currentTheme+" target: "+getThemeByPosition(new_target_leave);
			do goto target: new_target_leave;
			
		}
	}
	
	// every 150 cycles, all the guests except the guests in stadium should change places
	reflex updateStage when: timer mod 150 = 0 and targetStage != stageList[3]{
		do add_desire(change_place, 4.0);
	}
	
	action updateColor(string type){
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
	}
	
	
	
	// every 150 cycles, all the guests except the guests in stadium should change places
	plan change_the_place intention: change_place{
//		bool gotoStage <- flip(0.8);
		//update color
		do updateColor(type);

		//decide the target
		if(targetStage=nil){
			targetStage <- stageList[rnd(0,length(stageList)-2)];			
		}
		// get the coordinate for the new target stage 
		point new_target_relocate <- getPositionByStageTheme(targetStage.theme);
		
		if(new_target_relocate distance_to location<=5){
			target <- new_target_relocate;
			// update the stage satisfaction
			do increaseSatisfaction(getThemeByPosition(target));
			// already leave the original place, remove the desire
			// the attend_activity intention should now be executed
			do remove_desire(change_place);
			currentTheme <- getThemeByPosition(new_target_relocate);
			do wander;
			targetStage <- nil;
		}else{
			// go to the new coordinate and clear the targetStage
//			write "timer"+timer+"[change]currentTheme: "+currentTheme+" target: "+getThemeByPosition(new_target_relocate);
			do goto target: new_target_relocate;
		}
	}
	
	action increaseSatisfaction(string theme){
		if(theme='film'){
			film_satisfaction <- film_satisfaction + rnd(1.0, 2.0);
		}else if(theme = 'game discussion corner'){
			game_corner_satisfaction <- game_corner_satisfaction + rnd(1.0, 2.0);
		}else if(theme = 'bar'){
			bar_satisfaction <- bar_satisfaction + rnd(1.0, 2.0);
		}else if(theme='stadium'){
			if(type='PUBG lover' or type='Fortnite lover'){
				stadium_satisfaction <- stadium_satisfaction + rnd(3.0,4.0);
			}else{
				stadium_satisfaction <- stadium_satisfaction + rnd(1.0, 2.0);
			}
		}
	}
	
	action decreaseSatisfaction(string theme){
		if(theme='film'){
			film_satisfaction <- film_satisfaction - rnd(5.0, 6.0);
		}else if(theme = 'game discussion corner'){
			game_corner_satisfaction <- game_corner_satisfaction - rnd(5.0, 6.0);
		}else if(theme = 'bar'){
			bar_satisfaction <- bar_satisfaction - rnd(5.0, 6.0);
		}
	}
	
	plan leave_contest intention: leave_contest{
		if(targetStage=nil){
			targetStage <- stageList[rnd(0,length(stageList)-2)];			
		}
		// get the coordinate for the new target stage 
		point new_target_relocate <- getPositionByStageTheme(targetStage.theme);
		if(new_target_relocate distance_to location<=5){
			target <- new_target_relocate;
			
			// update the stage satisfaction
			do increaseSatisfaction(getThemeByPosition(target));
			
			// already leave the original place, remove the desire
			// the attend_activity intention should now be executed
			do remove_desire(leave_contest);
			currentTheme <- getThemeByPosition(new_target_relocate);
			do wander;
			targetStage <- nil;
		}else{
			// go to the new coordinate and clear the targetStage
			do goto target: new_target_relocate;
		}
	}
	
	plan join_contest intention: join_contest{
		// select the stadium as target
		if(targetStage=nil){
			targetStage <- stageList[3];
		}
		
		point new_target <- getPositionByStageTheme(targetStage.theme);
		
		if(new_target distance_to location<=5){
			target <- new_target;
			do increaseSatisfaction(targetStage.theme);
			// already leave the original place, remove the desire
			// the attend_activity intention should now be executed
			do remove_desire(join_contest);
			currentTheme <- getThemeByPosition(new_target);
			do wander;
			targetStage <- nil;
		}else{
			// go to the new coordinate and clear the targetStage
//			write "timer"+timer+"[contest]currentTheme: "+currentTheme+" target: "+getThemeByPosition(new_target);
			do goto target: new_target;
		
		}
	}
	
	// initially, just wander to find a place to have some activity
	plan lets_wander intention: find_activities{
		do wander;
	}
	
	
	plan attend_an_activity intention: attend_activity  {
        if (target = nil) {
            do add_subintention(get_current_intention(),choose_activity, true);
            do current_intention_on_hold();
        } else {
        	
            if (target distance_to location <= 5)  {
				list<string> broadcast_content;
				
            	currentTheme <- getThemeByPosition(target);
            	// the agent should broadcast his type, the target (stage) theme (bar, film, game discussion corner) and the trait value
            	if(type = "party" and currentTheme="bar"){
            		broadcast_content <- [type, currentTheme, self.generous];
            	}else if(type="bad children" and currentTheme="film"){
            		broadcast_content <- [type, currentTheme];
            	}else if(type="PUBG lover" and currentTheme="game discussion corner"){
            		broadcast_content <- [type, currentTheme, self.aggressive];
            	}
            	
            	// only broadcast with the matched guest type and theme
            	if(length(broadcast_content)>0){
            		do start_conversation (to: guestList , protocol: 'no-protocol', performative: 'inform', contents: broadcast_content);
            	}
            					
				do wander;
                target <- nil;
            }else{
            	do goto target: target;
            }
        }    
    }
    
    string getThemeByPosition(point target){
    	if(target={25,25}){
    		return "bar";
    	}else if(target={25,75}){
    		return "game discussion corner";
    	}else if(target={75,25}){
    		return "film";
    	}else{	// {75, 75}
    		return "stadium";
    	}
    		
    }
    
    point getPositionByStageTheme(string stageTheme){
    	point res <- nil;
    	if(stageTheme="bar"){
    		res <- {25,25};
    	}else if(stageTheme="game discussion corner"){
    		res <- {25,75};
    	}else if(stageTheme="film"){
    		res <- {75,25};
    	}else{
    		res <- {75,75};
    	}
    	return res;
    }

//choose the closet activity
	plan choose_closest_activity intention: choose_activity instantaneous:true{
		//get stage locations from belief
        list<point> possible_activity_locations <- get_beliefs_with_name(activity_at_location) collect (point(get_predicate(mental_state (each)).values["location_value"]));
		//get the closest one
		target <- (possible_activity_locations with_min_of (each distance_to self)).location;
		
		do remove_intention(choose_activity, true);
	}
	
	
	reflex receiveBroadcast when: !(empty(informs)){
		
		list<message> msg <- informs;
		loop m over:msg{
			list content <- list(m.contents);
			string peopleType <- string(content[0]);
			bool senderAtStage <- false;
			
			if(peopleType="bad children" and self.type="chill" and getThemeByPosition(target)="film" and currentTheme="film"){	// if my theme is same as the bad children's
				ask Guest{
					if (self =m.sender){
						if(currentTheme = 'film' and self.location distance_to stageList[2] <= 5){
							senderAtStage <- true;
						}
					}
				}
				
				if(senderAtStage){
					//************************
					//threshold is 0.7
					if(self.didactic<0.7){
						// leave
						write '['+ self + ', ' + self.type + ']' + ': I am annoyed by bad children at film.';
						do add_desire(leave_place, 3.0);
						break;
					}else{
						// stay
						write '['+ self + ', ' + self.type + ']' + ': I stay with bad children at film.';
						
					}
				
				}
				
			}else if(peopleType="PUBG lover" and self.type="Fortnite lover" and getThemeByPosition(target)="game discussion corner" and currentTheme="game discussion corner"){
				float aggressiveFactor <- float(content[2]);
				
				ask Guest{
					if (self =m.sender){
						if(currentTheme = 'game discussion corner' and self.location distance_to stageList[1] <= 5){
							
							senderAtStage <- true;
						}
					}
				}
				if(senderAtStage){
					//************************
					//PUBG and Fortnite lover both are aggressive, then they will fight
					if(aggressiveFactor >= 0.7 and self.aggressive >= 0.7){
						// leave
						write '['+ self + ', ' + self.type + ']' + ': I leave and let PUBG lover leave';
						do add_desire(leave_place, 3.0);
						// ask PUBG to leave
						list<string> broadcast_content <- ["Fortnite lover", "conflict"];
						do start_conversation (to: guestList , protocol: 'no-protocol', performative: 'inform', contents: broadcast_content);			
						break;
					}else{
						// stay
						write "Fortnite lover and PUBG lovers play together";
					}
				}
			}else if(peopleType="party" and self.type="chill" and getThemeByPosition(target)="bar" and currentTheme="bar"){
				float generousFactor <- float(content[2]);
				
				ask Guest{
					if (self =m.sender){
						if(currentTheme = 'bar' and self.location distance_to stageList[0] <= 5){
							
							senderAtStage <- true;
						}
					}
				}
				
				if(senderAtStage){
					//************************
					//threshold is 0.7
					if(generousFactor<0.7){
						// leave
						write '['+ self + ', ' + self.type + ']' + ': party people is not so generous';
						do add_desire(leave_place, 3.0);
						break;
					}else{
						// stay
						write '['+ self + ', ' + self.type + ']' + ': I accept the invitation from party people';
					}
				
				}
			}else if(peopleType="Fortnite lover" and self.type="PUBG lover" and currentTheme="game discussion corner"){
				ask Guest{
					if (self =m.sender){
						if(currentTheme = 'game discussion corner' and self.location distance_to stageList[1] <= 5){
							
							senderAtStage <- true;
						}
					}
				}
				
				if(senderAtStage){
					write '['+ self + ', ' + self.type + ']' + ': I leave and because there is Fortnite lovers';
					do add_desire(leave_place, 3.0);
					break;
					
				}
				
			}
			
		}
		informs <- [];
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
			
			if(gotoStadium){	
				do updateColor(type);
				do add_desire(join_contest, 5.0);
			}	
		
		}else if (status = 'end'){
			targetStage<-nil;
			do add_desire(leave_contest, 9.0);
		}
	
	}
	
	aspect base{
		draw sphere(1) color: color;
	}
}

species Stage skills:[fipa] {
	rgb color;
	point position;
	
	int timer <- 0 update: time + 1;
	
	bool beginNewContest <- false;
	int beginTime <- 0;
	int endTime <- 0;
	string type;//contest type if stage is a stadium
	
	string theme; // bar, film, game discussion corner
    aspect base{
		draw triangle(8) color: #orange;
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
			
			do start_conversation (to: guestList , protocol: 'fipa-contract-net', performative: 'request', contents: ['stadium', type, 'begin']);
			endTime <- beginTime + 100;
			beginNewContest <- true;
		}
		
		
	}
	
	reflex endStadiumContest when:theme = 'stadium' and beginNewContest and (timer = endTime) {
		beginNewContest <- false;
		write '[' + self + ']' + ' : stadium ends ' + type ; 
		do start_conversation (to: guestList , protocol: 'fipa-contract-net', performative: 'request', contents: ['stadium', type ,'end']);
	}
	

	
}

experiment main type: gui {
    output {
        display map type: opengl {	
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
        
        
    }
    

    

}