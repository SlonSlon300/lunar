# check_pwpolicy
#
# Function to check pwpolicy output under OS X
#.

check_pwpolicy() {
  if [ "$os_name" = "Darwin" ]; then
    parameter_name=$1
    correct_value=$2
    log_file="$parameter_name.log"
    if [ "$audit_mode" != 2 ]; then
      echo "Checking:  Password Policy for \"$parameter_name\" is set to \"$correct_value\""
      if [ "$managed_node" = "Error" ]; then
        actual_value=`sudo pwpolicy -n /Local/Default -getglobalpolicy $parameter_name 2>&1 |cut -f2 -d=`
      else
        actual_value=`sudo pwpolicy -n -getglobalpolicy $parameter_name 2>&1 |cut -f2 -d=`
      fi
      if [ "$actual_value" != "$correct_value" ]; then
        if [ "$audit_mode" = 1 ]; then
          
          
          increment_insecure "Password Policy for \"$parameter_name\" is not set to \"$correct_value\""
          verbose_message "" fix
          if [ "$managed_node" = "Error" ]; then
            verbose_message "sudo pwpolicy -n /Local/Default -setglobalpolicy $parameter_name=$correct_value" fix
          else
            verbose_message "sudo pwpolicy -n -setglobalpolicy $parameter_name=$correct_value" fix
          fi
          verbose_message "" fix
        fi
        if [ "$audit_mode" = 0 ]; then
          log_file="$work_dir/$log_file"
          echo "Setting:   Password Policy for \"$parameter_name\" to \"$correct_value\""
          echo "$actual_value" > $log_file
          if [ "$managed_node" = "Error" ]; then
            sudo pwpolicy -n /Local/Default -setglobalpolicy $parameter_name=$correct_value
          else
            sudo pwpolicy -n -setglobalpolicy $parameter_name=$correct_value
          fi
        fi
      else
        if [ "$audit_mode" = 1 ]; then
          
          
          increment_secure "Password Policy for \"$parameter_name\" is set to \"$correct_value\""
        fi
      fi
    else
      log_file="$restore_dir/$log_file"
      if [ -f "$log_file" ]; then
        previous_value=`cat $log_file`
       if [ "$previous_value" != "$actual_value" ]; then
          echo "Restoring: Password Policy for \"$parameter_name\" to \"$previous_value\""
          if [ "$managed_node" = "Error" ]; then
            sudo pwpolicy -n /Local/Default -setglobalpolicy $parameter_name=$previous_value
          else
            sudo pwpolicy -n -setglobalpolicy $parameter_name=$previous_value
          fi
        fi
      fi
    fi
  fi
}
