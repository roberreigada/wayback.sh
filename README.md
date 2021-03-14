wayback.sh is a simple script written in Bash used to extract data from the Waybackmachine.

# Basic usage
```sh
bash wayback.sh <url> <output_file> <number_of_different_dates_to_extract>
```

<b>Example 1:</b>

This command will extract the robots.txt file of google.com from the Waybackmachine for all the dates stored. (Really long execution as there will be a lot of dates)
```sh
bash wayback.sh https://www.google.com/robots.txt google_robots.txt
```

<b>Example 2:</b>

This command will extract the robots.txt file of google.com from the Waybackmachine for just the number of dates you specified in the third parameter. If you set the <number_of_different_dates_to_extract> parameter to 3 the tool will pick the first date, the last date, and 3 different dates equally distant in time
```sh
bash wayback.sh https://www.google.com/robots.txt google_robots.txt 3
```

<b>Example 3:</b>

This command will extract www.google.com main page from the Waybackmachine for just the number of dates you specified in the third parameter. In this case the second parameter will be ignored and a folder will be created storing the web pages for the different dates
```sh
bash wayback.sh https://www.google.com/ google.com.txt 3
```

 # Features
 - wayback.sh detects if the url contains a robots.txt path. If that's the case it will only extract the lines that contain "allow" (which also inludes dis-allow lines). This way we can easily create wordlists based in the endpoints extracted. The output will all be saved into the file specified after deleting all the duplicated entries.
 - If the endpoint in the url is not robots.txt wayback.sh will create a folder to store the results with the name format of YYYYMMDD_hhmmss, for example => "20210314_000118". With all the results obtained wayback.sh will grep and extract all html/php/asp/aspx/js files and put them into htmlphpaspxjsfiles.txt. Also it will check all the responses saved and store all the different variables found in the code in the file parameters.txt.
 
