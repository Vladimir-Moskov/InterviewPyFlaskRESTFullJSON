# InterviewPyRevolut
Date: 2020-01-24
Created By: Volodymyr Moskov


##Interview for Python Developer (Data) position in Revolut (Berlin/London)

*Please see task details in file "Python Engineer Data Challenge.pdf" (or .txt)


# Here is solution

### Please see solution for SQL part in ./postgres_sql_task

### Please see solution for Task 1 in ./group_currency_util/currency_parser.py
Simple python module which doing the job and can be use as stand alon script to
run it from command line or can be reused as module in order to parse data for API application

### Please see solution for Task 2 in ./api/group_currency_api.py
Simple API has been made with Flask, simple as it possible


  1. Flask ecosystem has been used to implement REST api task.
  2. Used in memory DB to store data from POST request.
  3. base authorization by token has been implemented - as simple as possible


## Project source code on github -

## From point of view MVP (Minimum Valuable Product)

1. For simplicity - logging has been added as it was asked
   "Any debugging or logging information should be printed to stderr"

2. For simplicity - unit tests and integration tests has been implemented as it was asked

3. For simplicity - only base authorization/security has been implemented as it was asked


## Project setup steps (Windows only)

 1. download project into your local disc or do VCS - Check out from version
    if you use Pycharm

 2. Install latest Python 3.7 if you do not have [https://realpython.com/installing-python/]
    and run cmd console

 3. Install pip  use command
   > python get-pip.py
   or follow step by step [https://www.liquidweb.com/kb/install-pip-windows/]

 4. Install Python virtualenv with command
   > pip install virtualenv

 5. set project folder as you current folder
    > cd   your_local_folder/InterviewPyRevolut

 6. Run next command in order to create virtualenv for project
   > virtualenv venv

 7. Activate virtual environment
   > your_local_folder/InterviewPyRevolut/venv/Scripts/activate

 8. install project dependencies

   > pip install -r ../../requirements.txt

    and use

    > pip freeze > ../../requirements.txt

    in order to update list of project libraries
    and use

    > pip install <package-name>

    in case you miss some


 ## Run instructions
 ### Start json parser
    > application that group json by field (Task 1)
    1. Here is where application located -
        > InterviewPyRevolut/group_currency_util/currency_parser.py

     it maybe used with file /resource/currency.json

    2. use command (as it mentioned in task)
        for Windows
        > type InterviewPyRevolut\resource\currency.json | python currency_parser.py currency country city

        for Linux
        cat InterviewPyRevolut\resource\currency.json | python currency_parser.py currency country city

 ### Start REST application (Flask + flask_restful)
    > Create a REST service from the first task.

    1.  Here is where application located -
        > InterviewPyRevolut/api/group_currency_api.py

    2. Run it with
       >  python InterviewPyRevolut/api/group_currency_api.py

    3. application will be started on

        > http://localhost:5001/

        or

        >http://127.0.0.1:5001/

        API methods:
            Use token=RevolutAPI for authorization

            # POST - http://127.0.0.1:5001/api/v1/groupCurrency
            Save original JSON on the server side (iMDB)

            Simple use
            > POST - http://127.0.0.1:5001/api/v1/groupCurrency
            Use with token
            > POST - http://127.0.0.1:5001/api/v1/groupCurrency?token=RevolutAPI

            #GET - http://127.0.0.1:5001/api/v1/groupCurrency?token=RevolutAPI

            Simple use
            > GET - http://127.0.0.1:5001/api/v1/groupCurrency?token=RevolutAPI

            Use with token
            > GET - http://127.0.0.1:5001/api/v1/groupCurrency?token=RevolutAPIGET

            Use with arguments
            > GET - http://127.0.0.1:5001/api/v1/groupCurrency?token=RevolutAPI&parameters=currency,country,city

