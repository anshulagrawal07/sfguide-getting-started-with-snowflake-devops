USE ROLE ACCOUNTADMIN;

CREATE WAREHOUSE IF NOT EXISTS GIT_WH WAREHOUSE_SIZE = XSMALL, AUTO_SUSPEND = 300, AUTO_RESUME= TRUE;


-- Separate database for git repository
CREATE DATABASE IF NOT EXISTS git_int_test;


-- API integration is needed for GitHub integration
CREATE OR REPLACE API INTEGRATION git_api_integration
  API_PROVIDER = git_https_api
  API_ALLOWED_PREFIXES = ('https://github.com/anshulagrawal07') -- INSERT YOUR GITHUB USERNAME HERE
  ENABLED = TRUE;


-- Git repository object is similar to external stage
CREATE OR REPLACE GIT REPOSITORY git_int_test.public.git_repo
  API_INTEGRATION = git_api_integration
  ORIGIN = 'https://github.com/anshulagrawal07/sfguide-getting-started-with-snowflake-devops'; -- INSERT URL OF FORKED REPO HERE


CREATE OR REPLACE DATABASE git_int_prod;


-- To monitor data pipeline's completion
CREATE OR REPLACE NOTIFICATION INTEGRATION email_integration
  TYPE=EMAIL
  ENABLED=TRUE;


-- Database level objects
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;


-- Schema level objects
CREATE OR REPLACE FILE FORMAT bronze.json_format TYPE = 'json';
CREATE OR REPLACE STAGE bronze.raw;


-- Copy file from GitHub to internal stage
copy files into @bronze.raw from @git_int_test.public.git_repo/branches/main/data/airport_list.json;
