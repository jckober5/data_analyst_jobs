create or replace view external_data.vw_google_job_data as # Add additional fields to have data ready for analysis
	SELECT
		*
	    , CASE # Determine if it's a senior level role
	        WHEN LOWER(gjd.title) LIKE '%sr%' THEN 1
	        WHEN LOWER(gjd.title) LIKE '%senior%' THEN 1
	        ELSE 0
	    END AS senior_position
	    , CASE # Detemine if it's a contractor type position
	        WHEN LOWER(gjd.schedule_type) LIKE '%contract%' THEN 1
	        ELSE 0
	    END AS contract_offer
	    , REGEXP_SUBSTR(lower(title), '\\w+(?=\\s+analyst)', 1, 1) as specialty # attempt to determine the specialty of analytics (data, marketing, finance, etc)
	    , CASE # Determine the salary annually if considered full time, 2080 hrs a year, if it is given in the posting
		    WHEN salary LIKE '___K–___K a year' THEN CAST(SUBSTRING(salary, 1, 3) AS UNSIGNED) * 1000
	        WHEN salary LIKE '__K–__K a year' THEN CAST(SUBSTRING(salary, 1, 2) AS UNSIGNED) * 1000
	        WHEN salary LIKE '__–__ an hour' THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(salary, '–', 1), ' ', -1) AS UNSIGNED) * 2080
	        WHEN salary LIKE '___K–__K a year' THEN CAST(SUBSTRING(salary, 1, 3) AS UNSIGNED) * 1000
	        WHEN salary LIKE '___–__ an hour' THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(salary, '–', 1), ' ', -1) AS UNSIGNED) * 2080
	        WHEN salary LIKE '____K–___K a year' THEN CAST(SUBSTRING(salary, 1, 4) AS UNSIGNED) * 1000
	        WHEN salary LIKE '__K a year' THEN CAST(SUBSTRING(salary, 1, 2) AS UNSIGNED) * 1000
	        WHEN salary LIKE '__K–___K a year' THEN CAST(SUBSTRING(salary, 1, 2) AS UNSIGNED) * 1000
	        WHEN salary LIKE '__,___–___,___ a year' THEN CAST(SUBSTRING(salary, 1, 2) AS UNSIGNED) * 1000
	        WHEN salary LIKE '____–___ an hour' THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(salary, '–', 1), ' ', -1) AS UNSIGNED) * 2080
	        WHEN salary LIKE '__.__–__.__ an hour' THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(salary, '–', 1), ' ', -1) AS UNSIGNED) * 2080
	        WHEN salary LIKE '__ an hour' THEN CAST(SUBSTRING(salary, 1, 3) AS UNSIGNED) * 2080
	    END AS annual_full_time_salary
	FROM
	    external_data.google_job_data gjd
;
select title, schedule_type , annual_full_time_salary from external_data.vw_google_job_data vgjd ;

create or replace view external_data.vw_google_job_data_skills as # Aggregate fields by skills to show what is offered for each skill 
	SELECT 
		'Tableau' as skill
		, SUM(tableau) as requests
		, count(tableau) as postings
		, round(avg(case 
			when tableau = 1 then annual_full_time_salary
			else null
		end), 0) as avg_salary
		, count(case 
			when tableau = 1 then annual_full_time_salary
			else null
		end) as shown_salaries
		, sum(case 
			when tableau = 1 and senior_position = 1 then 1
			else 0
		end) as senior_positions_offered
		, sum(senior_position) as senior_positions_total
	from 
		external_data.vw_google_job_data gjd 
union
	SELECT 
		'Power BI' as skill
		, SUM(power_bi) as requests
		, count(power_bi) as postings
		, round(avg(case 
			when power_bi = 1 then annual_full_time_salary
			else null
		end), 0) as avg_salary
		, count(case 
			when power_bi = 1 then annual_full_time_salary
			else null
		end) as shown_salaries
		, sum(case 
			when power_bi = 1 and senior_position = 1 then 1
			else 0
		end) as senior_positions_offered
		, sum(senior_position) as senior_positions_total
	from 
		external_data.vw_google_job_data gjd
union
	SELECT 
		'Excel' as skill
		, SUM(excel) as requests
		, count(excel) as postings
		, round(avg(case 
			when excel = 1 then annual_full_time_salary
			else null
		end), 0) as avg_salary
		, count(case 
			when excel = 1 then annual_full_time_salary
			else null
		end) as shown_salaries
		, sum(case 
			when excel = 1 and senior_position = 1 then 1
			else 0
		end) as senior_positions_offered
		, sum(senior_position) as senior_positions_total
	from 
		external_data.vw_google_job_data gjd
union
	SELECT 
		'Looker' as skill
		, SUM(looker) as requests
		, count(looker) as postings
		, round(avg(case 
			when looker = 1 then annual_full_time_salary
			else null
		end), 0) as avg_salary
		, count(case 
			when looker = 1 then annual_full_time_salary
			else null
		end) as shown_salaries
		, sum(case 
			when looker = 1 and senior_position = 1 then 1
			else 0
		end) as senior_positions_offered
		, sum(senior_position) as senior_positions_total
	from 
		external_data.vw_google_job_data gjd
union
	SELECT 
		'SAS' as skill
		, SUM(sas) as requests
		, count(sas) as postings
		, round(avg(case 
			when sas = 1 then annual_full_time_salary
			else null
		end), 0) as avg_salary
		, count(case 
			when sas = 1 then annual_full_time_salary
			else null
		end) as shown_salaries
		, sum(case 
			when sas = 1 and senior_position = 1 then 1
			else 0
		end) as senior_positions_offered
		, sum(senior_position) as senior_positions_total
	from 
		external_data.vw_google_job_data gjd
union
	SELECT 
		'R' as skill
		, SUM(r) as requests
		, count(r) as postings
		, round(avg(case 
			when r = 1 then annual_full_time_salary
			else null
		end), 0) as avg_salary
		, count(case 
			when r = 1 then annual_full_time_salary
			else null
		end) as shown_salaries
		, sum(case 
			when r = 1 and senior_position = 1 then 1
			else 0
		end) as senior_positions_offered
		, sum(senior_position) as senior_positions_total
	from 
		external_data.vw_google_job_data gjd
union
	SELECT 
		'Python' as skill
		, SUM(python) as requests
		, count(python) as postings
		, round(avg(case 
			when python = 1 then annual_full_time_salary
			else null
		end), 0) as avg_salary
		, count(case 
			when python = 1 then annual_full_time_salary
			else null
		end) as shown_salaries
		, sum(case 
			when python = 1 and senior_position = 1 then 1
			else 0
		end) as senior_positions_offered
		, sum(senior_position) as senior_positions_total
	from 
		external_data.vw_google_job_data gjd
union
	SELECT 
		'SQL' as skill
		, SUM(sql_skills) as requests
		, count(sql_skills) as postings
		, round(avg(case 
			when sql_skills = 1 then annual_full_time_salary
			else null
		end), 0) as avg_salary
		, count(case 
			when sql_skills = 1 then annual_full_time_salary
			else null
		end) as shown_salaries
		, sum(case 
			when sql_skills = 1 and senior_position = 1 then 1
			else 0
		end) as senior_positions_offered
		, sum(senior_position) as senior_positions_total
	from 
		external_data.vw_google_job_data gjd
union
	SELECT 
		'AI/ML' as skill
		, SUM(requested_ai_experience) as requests
		, count(requested_ai_experience) as postings
		, round(avg(case 
			when requested_ai_experience = 1 then annual_full_time_salary
			else null
		end), 0) as avg_salary
		, count(case 
			when requested_ai_experience = 1 then annual_full_time_salary
			else null
		end) as shown_salaries
		, sum(case 
			when requested_ai_experience = 1 and senior_position = 1 then 1
			else 0
		end) as senior_positions_offered
		, sum(senior_position) as senior_positions_total
	from 
		external_data.vw_google_job_data gjd
;
select * from external_data.vw_google_job_data_skills vgjds;