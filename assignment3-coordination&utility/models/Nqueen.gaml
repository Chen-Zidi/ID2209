/**
* Name: Nqueen
* Based on the internal empty template. 
* Author: Spycsh
* Tags: 
*/


model Nqueen

/* Insert your model definition here */

// should have a global 2D array to store the predecessors' positions
// the array should be forwarded from predecessor to the successor
// the successor should judge whether it is valid to put for each column

global
{
	
	int number_of_queens <- 8;
	
	list<Queen> queenList;
	int col <- 0;
	
	
	init
	{
		create Queen number: number_of_queens
		{
			location <- QueenGrid[col,0].location;
			
			self.column <- col;
			col <- col +1;
			
			if(length(queenList)>0)
			{
				self.predecessor <- queenList[length(queenList) - 1];
				queenList[length(queenList) - 1].successor <- self;
			}
			queenList << self;	
		}
		
		ask queenList[0]{
			self.column <- 0;
			self.row <- 0;
		}
	}
}

species Queen skills:[fipa, moving]
{
	int column <- nil;
	int row <- 0;
	Queen predecessor <- nil;
	Queen successor <- nil;
	
	matrix globalMatrix <- 0 as_matrix({number_of_queens, number_of_queens});
	
	bool startFlag <- false;
	
	// for the first queen, send itself a message to start finding the positions
	reflex startPlacing when: startFlag=false and column=0{
		startFlag<- true;
		do start_conversation to: [queenList[0]] protocol: 'no-protocol' performative: 'propose' contents: [globalMatrix];
	}

	
	reflex receivePredecessorMsg when: !(empty(proposes))
	{
		if(column>0){
			write "queen " + column + " receives a propose from queen " + (column-1) + " that it can choose and update its position.";
		}else{
			write "queen 1 start the finding process.";
		}

		globalMatrix <- list(proposes[0].contents)[0];
		row<-0;
		// find an appropriate row of the queen at its column
		loop while: row < number_of_queens{
			if(checkValidity(column, row)){
				
				do clearColumn;
				do placeMyPosition;
				// if check the last queen success, then return the success msg to predecessor
				if(column=number_of_queens-1){
				//	do start_conversation to: [predecessor] protocol: 'no-protocol' performative: 'inform' contents: ["success"];
					write("Queens find a success situation like follows!");
					write globalMatrix;	
				}else{
					do start_conversation to: [successor] protocol: 'no-protocol' performative: 'propose' contents: [globalMatrix];		
				}
				break;
			}else{
				row<-row+1;
			}
		}
		
		// if no suitable position, then inform its predecessor
		if row>=number_of_queens{
			do clearColumn;
			write "queen " + column + " fails to find an appropriate position.";
			do start_conversation to: [predecessor] protocol: 'no-protocol' performative: 'inform' contents: ["fail"];
			
		}
	}
	
	// receive reply from the successor
	reflex receiveSuccessorMsg when: !(empty(informs)){
		write "queen " + column + " receive a reply from queen " + (column+1) + " that it need to change its position.";
		string msg <- list(informs[0].contents)[0];
		if(msg='fail'){
			row<-row+1;
			
			loop while: row<number_of_queens{
				if(checkValidity(column, row)){
					do clearColumn;
					do placeMyPosition;
					do start_conversation to: [successor] protocol: 'no-protocol' performative: 'propose' contents: [globalMatrix];
					break;
				}else{
					row<-row+1;
				}	
			}
			
			if(row>=number_of_queens){
				// if no suitable position of the first queen (no predecessor), that means all position sets have been checked, write "no solution"		
				if(column=0){
					do clearColumn;
					write "no solution!";
				}else{
					do clearColumn;
					write "queen " + column + " fails to find an appropriate position.";
					do start_conversation to: [predecessor] protocol: 'no-protocol' performative: 'inform' contents: ["fail"];
				}
			}
						
		}
		
	}
	
	
	
	// whether it is valid at the row and column
	bool checkValidity(int col, int row)
	{
		// check if left side has queens
		int c<-0;
		int r<-row;
		loop while: c<col{
			if(globalMatrix[c, r]=1){
				return false;
			}
			c<-c+1;
		}
		
		// check if top-left has queens
		c<-col;
		r<-row;
		loop while: c>=0 and r>=0{
			if(globalMatrix[c, r]=1){
				return false;
			}
			c<-c-1;
			r<-r-1;
		}
		
		//check if bottom-left has queens
		c<-col;
		r<-row;
		loop while: c>=0 and r<=number_of_queens-1{
			
			if(globalMatrix[c, r]=1){
				return false;
			}
			c<-c-1;
			r<-r+1;
		}
		
		return true;
	}
	
	// place the queen based on its column and row
	action placeMyPosition
	{
		// set the new position
		globalMatrix[column, row] <- 1;
		// change view
		point myPosition <- QueenGrid[column,row].location;
		write "queen "+ column + " goes to ("+ column + ", "+ row+")";
		do goto target: myPosition speed:100;
	}
	
	action clearColumn
	{
		// clear the column
		int counter <- 0;
		loop while: counter<number_of_queens{
			globalMatrix[column, counter] <- 0;
			counter<- counter + 1;
		}
		point myPosition <- QueenGrid[column, 0].location;
		do goto target: myPosition speed:100;
	}
	
	
	aspect base
	{
		draw sphere(2) color: #yellow;
	}
}

grid QueenGrid width:  number_of_queens height:  number_of_queens {
	rgb color <- bool(((grid_x + grid_y) mod 2)) ? #black : #white;
}

experiment main type:gui
{
	output
	{
		display map type:opengl
		{
			
			species Queen aspect:base;
			grid QueenGrid lines:#black;
		}
	}
	
}