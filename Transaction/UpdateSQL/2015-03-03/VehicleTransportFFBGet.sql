
/****** Object:  StoredProcedure [Vehicle].[VehicleTransportFFBReportGet]    Script Date: 4/3/2015 3:50:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--exec Vehicle.VehicleTransportFFBReportGet 'M1','01R628'
-- =============================================  
-- Created By : Babu Kumarasamy  
-- Modified By: Babu Kumarasamy, Gopinath  
-- Created date: 4th May 2009
-- Last Modified Date:  4th JUNE 2009, Monday February 22  
-- Module     : Vehicle  
-- Reports  : VehicleTransportFFB.rpt  
-- Description:	To fill the report VehicleTransportFFB.rpt
-- =============================================  
ALTER PROCEDURE [Vehicle].[VehicleTransportFFBReportGet]
-- Add the parameters for the stored procedure here
        @EstateID NVARCHAR(50),
        --@LogedInMonth INT,
        --@LogedInYear  INT
        @ActiveMonthYearID NVARCHAR(50)
AS
        BEGIN
                -- SET NOCOUNT ON added to prevent extra result sets from
                -- interfering with SELECT statements.
                SET NOCOUNT ON;
                
    Declare @Minutes as float
	Declare @Hours as float
	Declare @HoursFromMunite as Float
	DECLARE @TotalHrs NVARCHAR(25)
	
	SELECT  @Hours=sum(cast (substring(CAST(VHRL.TotalHrs AS VARCHAR),0,CHARINDEX(':',CAST(VHRL.TotalHrs AS VARCHAR))) as int)),
			@Minutes= sum(cast( substring(CAST(VHRL.TotalHrs AS VARCHAR),CHARINDEX(':',CAST(VHRL.TotalHrs AS VARCHAR))+1,2) as int)) 
			FROM    Vehicle.VHRunningLog   AS VHRL
                              INNER JOIN General.ActiveMonthYear GAMY 
       							ON VHRL.ActiveMonthYearID = GAMY.ActiveMonthYearID
       							INNER JOIN Vehicle.VHWSMasterHistory AS VWMAS
       							ON VHRL.VHID = VWMAS.VHID AND VWMAS.AMonth = GAMY.AMonth AND VWMAS.AYear = GAMY.AYear 
       							INNER JOIN Vehicle.VHCategory VC
								ON VC.VHCategoryID = VWMAS.VHCategoryID
                              WHERE   VHRL.EstateID       = @EstateID
                                  --AND YEAR(VRL.LogDate)  = @LogedInYear
                                  --AND MONTH(VRL.LogDate) = @LogedInMonth
                                  AND VHRL.ActiveMonthYearID = @ActiveMonthYearID
                                  AND (VC.Category <> 'TE' OR VC.Category <> 'LV')
								  AND VHRL.Status = 'F'
                 
		
		SET	@HoursFromMunite=Floor(@Minutes/60)
		SET	@Hours=@Hours+@HoursFromMunite
		If(@HoursFromMunite>0)
			SET @Minutes= ((@Minutes/60)-@HoursFromMunite)*60
			
		 SET @TotalHrs= (SELECT ISNULL(cast(@Hours as varchar(5))+':'+ RIGHT('0'+ CONVERT(VARCHAR,@Minutes),2),'00:00'))
         
                
                
                
                
                -- Insert statements for procedure here
                SELECT VWMH.VHWSCode,
                       ET.EstateCode,
                       ET.EstateName,
                       VRL.Bunches  ,
                       VWMH.VHModel ,
                       CASE WHEN VWMH.UOM = 'K' THEN 'Kms' 
                       WHEN VWMH.UOM = 'H' THEN 'Hrs' 
                       END AS UOM
                       ,
                       /* VWMH.YOC  , */
                       VRL.LogDate                                ,
                      -- YOP.YOP                                    , --Field
                       YEAR(VWMH.PurDate) AS VehicleYear          ,
                      -- BM.BlockName                               ,
                       Cast(VRL.StartTime as nvarchar(50)) as StartTime,
                       Cast(VRL.EndTime as nvarchar(50)) as EndTIme,
                       VRL.TotalHrs                               ,
                       DIV.DivName,
                       YearOfPlan.YOP,
                       BM.BlockName,
                       --SumOfTotalHoursAndBunches.SumOfTotalBunches,
                       SumOfTotalHoursAndBunches.SumOfTotalHrs
                FROM   Vehicle.VHRunningLog                 AS VRL
                       --INNER JOIN Vehicle.VHWSMasterHistory AS VWMH
                       --ON     VWMH.VHID = VRL.VHID
                       INNER JOIN General.ActiveMonthYear GMY 
       					ON VRL.ActiveMonthYearID = GMY.ActiveMonthYearID
       					INNER JOIN Vehicle.VHWSMasterHistory AS VWMH
       					ON VRL.VHID = VWMH.VHID AND VWMH.AMonth = GMY.AMonth AND VWMH.AYear = GMY.AYear 
                       LEFT JOIN General.YOP
                       ON     YOP.YOPID = VRL.YOPID
                       INNER JOIN General.Estate AS ET
                       ON     ET.EstateID = VRL.EstateID
                       INNER JOIN Vehicle.VHCategory VHC
                       ON VHC.VHCategoryID = VWMH.VHCategoryID
                       LEFT JOIN General.Division AS DIV
                       ON DIV.DivID = VRL.DivID
                       LEFT JOIN General.YOP AS YearOfPlan
                       ON YearOfPlan.YOPID = VRL.YOPID
                       LEFT JOIN General.BlockMaster AS BM
                       ON     BM.BlockID = VRL.BlockID
                       INNER JOIN
                              (SELECT @TotalHrs AS SumOfTotalHrs
                              FROM    Vehicle.VHRunningLog  AS VHRL
                              INNER JOIN General.ActiveMonthYear GAMY 
       							ON VHRL.ActiveMonthYearID = GAMY.ActiveMonthYearID
       							INNER JOIN Vehicle.VHWSMasterHistory AS VWMAS
       							ON VHRL.VHID = VWMAS.VHID AND VWMAS.AMonth = GAMY.AMonth AND VWMAS.AYear = GAMY.AYear 
       							INNER JOIN Vehicle.VHCategory VC
								ON VC.VHCategoryID = VWMAS.VHCategoryID
                              WHERE   VHRL.EstateID       = @EstateID
                                  --AND YEAR(VRL.LogDate)  = @LogedInYear
                                  --AND MONTH(VRL.LogDate) = @LogedInMonth
                                  AND VHRL.ActiveMonthYearID = @ActiveMonthYearID
                                  AND (VC.Category <> 'TE' OR VC.Category <> 'LV')
								  AND VHRL.Status = 'F'
                              ) AS SumOfTotalHoursAndBunches
                       ON     1           = 1
                WHERE  VRL.EstateID       = @EstateID
                   --AND YEAR(VRL.LogDate)  = @LogedInYear
                   --AND MONTH(VRL.LogDate) = @LogedInMonth
                   AND VRL.ActiveMonthYearID = @ActiveMonthYearID
                   AND (VHC.Category <> 'TE' OR VHC.Category <> 'LV')
                   AND VRL.Status = 'F'
                   AND VRL .Posted ='Y'
                   --Added since it show empty records.
                  -- AND VRL.Bunches > 0 
         END


--ALTER PROCEDURE [Vehicle].[VehicleTransportFFBReportGet]
---- Add the parameters for the stored procedure here
--AS
--        BEGIN
--                -- SET NOCOUNT ON added to prevent extra result sets from
--                -- interfering with SELECT statements.
--                SET NOCOUNT ON;
--                -- Insert statements for procedure here
--                SELECT VWMH.VHWSCode,
--                       VRL.Bunches  ,
--                       VWMH.VHModel ,
--                       /* VWMH.YOC  , */
--                       VRL.LogDate                                ,
--                       YOP.YOP                                    ,
--                       BM.BlockName                               ,
--                       VRL.StartTime                              ,
--                       VRL.EndTime                                ,
--                       VRL.TotalHrs                               ,
--                       SumOfTotalHoursAndBunches.SumOfTotalBunches,
--                       SumOfTotalHoursAndBunches.SumOfTotalHrs
--                FROM   Vehicle.VHRunningLog                AS VRL
--                       LEFT JOIN Vehicle.VHWSMasterHistory AS VWMH
--                       ON     VWMH.VHID = VRL.VHID
--                       LEFT JOIN General.YOP
--                       ON     YOP.YOPID = VRL.YOPID
--                       LEFT JOIN General.BlockMaster AS BM
--                       ON     BM.BlockID = VRL.BlockID
--                       INNER JOIN
--                              (SELECT SUM(VRL.Bunches)                                                                                                                                                                                AS SumOfTotalBunches,
--                                      STUFF(CONVERT(CHAR(8), DATEADD(SECOND, ABS(SUM(DATEDIFF(SECOND, '00:00', VRL.TotalHrs))), '19000101'), 8), 1, 2, CAST(ABS(SUM(DATEDIFF(SECOND, '00:00', VRL.TotalHrs))) / 3600 AS VARCHAR(12))) AS SumOfTotalHrs
--                              FROM    Vehicle.VHRunningLog                                                                                                                                                                      AS VRL
--                              ) AS SumOfTotalHoursAndBunches
--                       ON     1 = 1
--                END
