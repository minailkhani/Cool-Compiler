class Node inherits A2I
{
    item: String;
    prev: Node;

    set_item(i: String, p:Node): Node
   {{
       item <- i;
       prev <- p;
       self;
   }};

   set_first_item(i: String): Node
   {{
       item <- i;
       self;
   }};
   get_head_item():String
   {{
   	item;
   }};
   get_prev():Node
   {{
	prev;
   }};
};
class StackCommand
{
    top:Node;
    newTop:Node;

    push(val:String): Object
    {{
    if (isvoid top) then
        {
            top <- new Node;
            top <- top.set_first_item(val);
        }
        else
        {
            newTop <- new Node;
            top <- newTop.set_item(val, top);
        }
        fi;
        
    }};
    head():String
    {{
       top.get_head_item();
    }};
    pop():Object
    {{
	top <- top.get_prev();
    }};
    display(): Object
    {
	let curr:Node <- top in 
	{
		while (not(isvoid curr)) loop
		{
			(new IO).out_string(curr.get_head_item().concat("\n"));
			curr <- curr.get_prev();
		}
	pool;
	}  
    };
};


class Main inherits A2I {
	i:IO <- new IO;
	st:StackCommand <- new StackCommand;
	temp1:String;
	temp2:String;
	main(): Object
  	{
		let command:String in
		{
			command <- "";
			
			while(not (command = "x")) loop
			{
				i.out_string("> ");
				command <- i.in_string();
				
				handel_command(command);
			}
		pool;
		}
	
   	};
	handel_command(command:String): Object
	{{
		if (command = "d") then
        	{
        		    st.display();
        	}
        	else
        	{
			if (command = "e")then
			{
				eval();
			}
			else
			{
				st.push(command);
			}
			fi;
		}
		fi;
	}};
	eval(): Object
	{{
		if (st.head() = "s")then
			{
				st.pop();
				
				temp1 <- st.head();
				st.pop();
				temp2 <- st.head();
				st.pop();

				st.push(temp1);
				st.push(temp2);
			}
			else
			{
				if (st.head() = "+")then
				{
					st.pop();
				
					temp1 <- st.head();
					st.pop();
					temp2 <- st.head();
					st.pop();

					st.push(i2a(a2i(temp1)+a2i(temp2)));
				}
				else
				{
					"";
				}
				fi;
			}
			fi;
	}};
};

