module ApplicationHelper

    def compare_tree_dir array_x, array_y
  
    i  = 0
    for x in array_x
        
        if array_y[i].nil?
            return 1
        else
            return -1 if array_y[i] != x
        end
        
        i += 1
    end
    return 0
  
  end
end
