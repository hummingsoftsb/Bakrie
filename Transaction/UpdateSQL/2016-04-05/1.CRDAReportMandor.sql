
/****** Object:  StoredProcedure [Checkroll].[CRDAReport]    Script Date: 22/3/2016 9:29:49 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Checkroll].[CRDAReportMandor] @EstateID          NVARCHAR(50), 
                                         @ActiveMonthYearID NVARCHAR(50) 
AS 
  BEGIN 
      select c_da.estateid, 
             g_estate.estatename, 
             c_da.activemonthyearid, 
             '' as gangname, 
             c_da.rdate, 
             c_emp.empcode, 
             c_emp.empname, 
             c_as.attendancecode, 
             Isnull(c_otd.ot1, 0)                  AS ot1, 
             Isnull(c_otd.ot2, 0)                  AS ot2, 
             Isnull(c_otd.ot3, 0)                  AS ot3, 
             Isnull(c_otd.ot4, 0)                  AS ot4, 
             g_amy.amonth, 
             g_amy.ayear, 
             c_emp .category,
			 c_as.TimesBasic as TotalHK,
			 IIF(c_as.attendancecode in ('AB','S0','SG','I0','TP','TP1','TP2','TP3','MT'),1,0) as totalabsent,
			IIF(c_as.attendancecode in ('S1','S2','S3','S4','CD'),1,0) as totalsick,
			IIF(c_as.attendancecode in ('L0','L1','JL'),1,0) as totaloffday,
			IIF(c_as.attendancecode in ('M0','M1'),1,0) as totalsunday,
			IIF(c_as.attendancecode in ('CB','CH','CT','I1','I2'),1,0) as totalleave,
			IIF(c_as.attendancecode in ('H1'),1,0) as totalrain
from Checkroll.DailyAttendanceMandor c_da
inner join Checkroll.CREmployee C_Emp on c_da.EmpID = C_Emp.EmpID
 LEFT JOIN checkroll.otdetail AS c_otd 
               ON c_da.empid = c_otd.empid 
                  AND c_da.rdate = c_otd.adate 
              INNER JOIN checkroll.attendancesetup AS c_as 
               ON c_da.attendancesetupid = c_as.attendancesetupid 
                  AND c_da.estateid = c_as.estateid 
             INNER JOIN general.estate AS g_estate 
               ON c_da.estateid = g_estate.estateid 
             INNER JOIN general.activemonthyear AS g_amy 
               ON c_da.activemonthyearid = g_amy.activemonthyearid
      WHERE  c_da.estateid = @EstateID 
             AND c_da.activemonthyearid = @ActiveMonthYearID 
      ORDER  BY
                c_emp.empcode, 
                c_da.rdate 
  END 
