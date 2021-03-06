
/****** Object:  StoredProcedure [Production].[DailyProductionReport]    Script Date: 5/25/2016 10:37:12 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ====================================================    
-- Created By : Gopinath   
-- Modified By: Palani
-- Created date: 24 Feb 2010    
-- Last Modified Date:  17 July 2013
-- Last Modified By: Naxim
-- Module     :[Production] , RKPMS Windows    
-- Screen(s)  : [Daily Production Report]
-- Description: To pull the record for the Daily Production Report
-- ===================================================== 
 
ALTER PROCEDURE [Production].[DailyProductionReport]
-- Add the parameters for the stored procedure here
@Date     DATETIME,
@EstateID NVARCHAR(50)--,
AS

BEGIN
      SET ansi_warnings OFF

      DECLARE @MonthFromDate DATETIME,
              @YearFromDate  DATETIME
     Declare @prevDaystock  numeric(18,3) =0      
       
      SET @MonthFromDate = (SELECT fy.fromdt
                            FROM   general.fiscalyear fy
                            WHERE  fy.fyear = Datepart(YEAR, @Date)
                                   --AND fy.period = Datepart(MONTH, @Date))
                                   AND @Date BETWEEN FromDT AND ToDT)
      SET @YearFromDate = (SELECT fy.fromdt
                           FROM   general.fiscalyear fy
                           WHERE  fy.fyear = Datepart(YEAR, @Date)
                                  AND fy.period = 1)
	print @MonthFromDate;
	

-- Palani                                  
declare @dtFrom as Date 
Select @dtFrom = FromDT  from General.FiscalYear where @Date between FromDT and ToDT

print '@dtFrom = ' + CAST(@dtFrom as varchar(50))

-- ### TABLE 0 ###
      SELECT CONVERT(DECIMAL(18, 3), t1.today_ffbprocessedact)           AS today_ffbprocessedact,
             t1.today_lorryprcessedact,
             t1.today_FFBReceived,
             
             ISNULL ( CONVERT(DECIMAL(18, 3),t2.today_FFBReceivedMTD),0)           AS today_FFBReceivedMTD,
             ISNULL ( CONVERT(DECIMAL(18, 3), t1.today_FFBReceivedYTD ),0)           AS today_FFBReceivedYTD,
             ISNULL ( CONVERT(DECIMAL(18, 3), t1.today_balanceffbcfqty),0)           AS today_balanceffbcfqty,
             t1.today_balanceffbcfnolorry,
             ISNULL (  CONVERT(DECIMAL(18, 3), t1.today_balanceffbbfqty),0)           AS today_balanceffbbfqty,
         --    CONVERT(DECIMAL(18, 3), t2.tomonth_ffbprocessedact)         AS tomonth_ffbprocessedact,
             ISNULL (  CONVERT(DECIMAL(18, 3), T2.tomonth_ffbprocessedact) ,0)         AS ToMonth_FFBProcessedACT,
             ISNULL (  CONVERT(DECIMAL(18, 3), K1.tomonth_LossOfKernelMTD) ,0)         AS ToMonth_LossOfKernelMTD,
             ISNULL (  CONVERT(DECIMAL(18, 3), t2.tomonth_balanceffbcfqty) ,0)         AS tomonth_balanceffbcfqty,
             ISNULL (  CONVERT(DECIMAL(18, 3), t2.tomonth_balanceffbbfqty) ,0)         AS tomonth_balanceffbbfqty,
          
             ISNULL (  CONVERT(DECIMAL(18, 3), K1.toyear_ffbprocessedact) ,0)          AS toyear_ffbprocessedact,
             ISNULL (   CONVERT(DECIMAL(18, 3), K1.toyear_LossOfKernelYTD),0)         AS ToYear_LossOfKernelYTD,
            ISNULL (   CONVERT(DECIMAL(18, 3), t3.toyear_balanceffbbfqty) ,0)         AS toyear_balanceffbbfqty,
             --- modified by kumar
            ISNULL (   CONVERT(DECIMAL(18, 3), t4.today_cpoqtytoday) ,0)              AS today_cpoqtytoday,
             ISNULL (  CONVERT(DECIMAL(18, 3), t4.month_cpoqty)  ,0)              AS month_cpoqty,
             ISNULL (   CONVERT(DECIMAL(18, 2), t4.today_oer)    ,0)                    AS today_oer,
             --ISNULL (  CONVERT(DECIMAL(18, 2), t5.tomonth_oer)   ,0)                   AS tomonth_oer,
            --ISNULL (   CONVERT(DECIMAL(18, 3), t5.tomonth_cpoqtytoday),0)             AS tomonth_cpoqtytoday,
            ISNULL (  CONVERT(DECIMAL(18, 2), ((month_cpoqty / t2.tomonth_ffbprocessedact) * 100)), 0) as tomonth_oer,
            ISNULL (   CONVERT(DECIMAL(18, 2), month_cpoqty), 0) as tomonth_cpoqtytoday,
            ISNULL (   CONVERT(DECIMAL(18, 2), t6.toyear_oer)   ,0)                   AS toyear_oer,
            ISNULL (   CONVERT(DECIMAL(18, 3), t6.toyear_cpoqtytoday),0)              AS toyear_cpoqtytoday,
            ISNULL (   CONVERT(DECIMAL(18, 3), t7.today_kernelqtytoday) ,0)           AS today_kernelqtytoday,
             ISNULL (  CONVERT(DECIMAL(18, 2), t7.today_ker) ,0)                     AS today_ker,
             --ISNULL (  CONVERT(DECIMAL(18, 2), t8.tomonth_ker) ,0)                    AS tomonth_ker,
             ISNULL (  CONVERT(DECIMAL(18, 3), t8.tomonth_kernelqtytoday) ,0)          AS tomonth_kernelqtytoday,
             ISNULL (  CONVERT(DECIMAL(18, 2), toyear_ker)  ,0)                        AS toyear_ker,
            ISNULL (   CONVERT(DECIMAL(18, 3), t9.toyear_kernelqtytoday)   ,0)         AS toyear_kernelqtytoday,
            ISNULL (   CONVERT(DECIMAL(18, 2), t10.today_cpoqualityffap),0)            AS today_cpoqualityffap,
            ISNULL (   CONVERT(DECIMAL(18, 2), t10.today_cpoqualitymoisturep) ,0)      AS today_cpoqualitymoisturep,
            ISNULL (   CONVERT(DECIMAL(18, 3), t10.today_cpoqualitydirtp) ,0)          AS today_cpoqualitydirtp,
            ISNULL (   CONVERT(DECIMAL(18, 3), t10.today_cpoqualityffapmtd),0)         AS today_cpoqualityffapmtd,
             
             ISNULL (  CONVERT(DECIMAL(18, 2), t13.today_kernelqualitybrokenkernel),0) AS today_kernelqualitybrokenkernel,
             ISNULL (  CONVERT(DECIMAL(18, 2), t13.today_kernelqualitymoisturep),0)    AS today_kernelqualitymoisturep,
            ISNULL (   CONVERT(DECIMAL(18, 3), t13.today_kernelqualitydirtp) ,0)       AS today_kernelqualitydirtp,
            ISNULL (   CONVERT(DECIMAL(18, 3), t16.today_ffb)     ,0)                  AS today_ffb,
             ISNULL (  CONVERT(DECIMAL(18, 3), t17.tomonth_ffb)   ,0)                  AS tomonth_ffb,
            ISNULL (   CONVERT(DECIMAL(18, 3), t18.toyear_ffb)    ,0)                  AS toyear_ffb,
             ISNULL (  CONVERT(DECIMAL(18, 3), t19.today_transcpo)   ,0)               AS today_transcpo,
             ISNULL (  CONVERT(DECIMAL(18, 3), t199.MTD_transcpo)   ,0)               AS MTD_transcpo,
             
             ISNULL (  CONVERT(DECIMAL(18, 3), t20.today_transkcp)  ,0)                AS today_transkcp,
            ISNULL (   CONVERT(DECIMAL(18, 3), t200.MTD_transKernel) ,0)                 AS MTD_transKernel,
             
           -- ISNULL (   CONVERT(DECIMAL(18, 3), (t21.laststockcpo + K21 .lastLoadcpo ))  ,0)                  AS laststockcpo,
			CASE When  K21 .lastLoadcpo = 0 then  ISNULL (   CONVERT(DECIMAL(18, 3), (t21.laststockcpo + K22 .lastLoadcpolast  ))  ,0) 
			ELSE  ISNULL (   CONVERT(DECIMAL(18, 3), (t21.laststockcpo + K21 .lastLoadcpo ))  ,0)  END
			AS laststockcpo,
            
            
            ISNULL (   CONVERT(DECIMAL(18, 3), t22.laststockkernel)  ,0)               AS laststockkernel,
             Isnull(t23.starttime, '00:00')                              AS starttime,
             Isnull(t23.stoptime, '00:00')                               AS stoptime,
             Isnull(t23.totaltime, '00:00')                              AS totaltime,
             Isnull(t24.today_mechanicalbd, '00:00')                     AS today_mechanicalbd,
             Isnull(t24.today_electricalbd, '00:00')                     AS today_electricalbd,
             Isnull(t24.today_processingbd, '00:00')                     AS today_processingbd,
             Isnull(t24.tomonth_mechanicalbd, '00:00')                   AS tomonth_mechanicalbd,
             Isnull(t24.tomonth_electricalbd, '00:00')                   AS tomonth_electricalbd,
             Isnull(t24.tomonth_processingbd, '00:00')                   AS tomonth_processingbd,
             Isnull(t24.toYear_mechanicalbd, '00:00')                   AS toyear_mechanicalbd,
             Isnull(t24.toYear_electricalbd, '00:00')                   AS toyear_electricalbd,
             Isnull(t24.toYear_processingbd, '00:00')                   AS toyear_processingbd,    
              Isnull(t24.MonthToDateHrs , '00:00')                   AS MonthToDateHrs,
              Isnull(t24.YearToDateHrs , '00:00')                   AS YearToDateHrs,
                      
             --t25.tomonth_mechanicalbd,
             --t25.tomonth_electricalbd,
             --t25.tomonth_processingbd,
             t26.totalpresshours,
             t27.remarks,
             t28.nounitsoperation
      FROM   (SELECT today_ffbprocessedact,
                     today_lorryprcessedact,
                     today_balanceffbcfqty,
                     today_balanceffbcfnolorry,
                     today_balanceffbbfqty,
                     today_FFBReceived,
                     today_FFBReceivedMTD ,
                     today_FFBReceivedYTD,
                     
                     Row_number() OVER(ORDER BY today_ffbprocessedact DESC) AS rc
              FROM   (SELECT Isnull(SUM(cpl.ffbprocessedact), 0)     AS today_ffbprocessedact,
                             Isnull(SUM(cpl.lorryprocessedact), 0)   AS today_lorryprcessedact,
                             Isnull(SUM(cpl.balanceffbcfqty), 0)     AS today_balanceffbcfqty,
                             Isnull(SUM(cpl.balanceffbcfnolorry), 0) AS today_balanceffbcfnolorry,
                             Isnull(SUM(cpl.balanceffbbfqty), 0)     AS today_balanceffbbfqty,
                             Isnull(SUM(cpl.FFBReceived ), 0)     AS today_FFBReceived ,
                             Isnull(SUM(cpl.FFBReceivedMTD ), 0)     AS today_FFBReceivedMTD ,
                             Isnull(SUM(cpl.FFBReceivedYTD ), 0)     AS today_FFBReceivedYTD 
                             
                              
                             -- To Add FFBREceivedYTD   
                      FROM   production.cpoproductionlog cpl
                             INNER JOIN general.cropyield gcy
                               ON cpl.cropyieldid = gcy.cropyieldid
                                  AND gcy.cropyieldcode = 'CPO'
                      WHERE  cpl.productionlogdate = @Date
                             AND cpl.estateid = @EstateID) x) AS t1
                             
             LEFT JOIN (SELECT tomonth_ffbprocessedact,
                               tomonth_balanceffbcfqty,
                               tomonth_balanceffbbfqty,
                               today_FFBReceivedMTD,
                               Row_number() OVER(ORDER BY tomonth_ffbprocessedact DESC) AS rc
                        FROM   (SELECT Isnull(SUM(cpl.FFBProcessedACT), 0) tomonth_ffbprocessedact,
                                       Isnull(SUM(cpl.balanceffbcfqty), 0) tomonth_balanceffbcfqty,
                                       Isnull(SUM(cpl.balanceffbbfqty), 0) tomonth_balanceffbbfqty,
                                       Isnull(SUM(cpl.FFBReceived ), 0) today_FFBReceivedMTD
                                FROM   production.cpoproductionlog cpl
                                       INNER JOIN general.cropyield gcy
                                         ON cpl.cropyieldid = gcy.cropyieldid
                                            AND gcy.cropyieldcode = 'CPO'
                                WHERE  cpl.estateid = @EstateID
                                       -- AND cpl.productionlogdate BETWEEN @MonthFromDate AND @Date) x)AS t2
                                       AND cpl.productionlogdate BETWEEN @dtFrom AND @Date) x)AS t2
               ON t1.rc = t2.rc
                LEFT JOIN (SELECT tomonth_ffbprocessedact,
								  toyear_ffbprocessedact,
								  tomonth_LossOfKernelMTD,
								  toyear_LossOfKernelYTD,
                               Row_number() OVER(ORDER BY tomonth_ffbprocessedact DESC) AS rc
                        FROM   (SELECT Isnull((cpl.FFBProcessedMTD), 0) tomonth_ffbprocessedact,
									   Isnull((cpl.FFBProcessedYTD), 0) toyear_ffbprocessedact,
									   Isnull((cpl.LossOfKernelMTD ), 0) tomonth_LossOfKernelMTD,
									   Isnull((cpl.LossOfKernelYTD ), 0) toyear_LossOfKernelYTD
                                       FROM   production.cpoproductionlog cpl
                                       INNER JOIN general.cropyield gcy
                                         ON cpl.cropyieldid = gcy.cropyieldid
                                            AND gcy.cropyieldcode = 'CPO'
                                WHERE  cpl.estateid = @EstateID
                                       AND cpl.productionlogdate = @Date) x)AS K1
               ON t1.rc = K1.rc
             LEFT JOIN (SELECT toyear_ffbprocessedact,
                               toyear_balanceffbbfqty,
                               today_FFBReceivedYTD,
                               Row_number() OVER(ORDER BY toyear_ffbprocessedact DESC) AS rc
                        FROM   (SELECT Isnull(SUM(cpl.ffbprocessedact), 0) toyear_ffbprocessedact,
                                       Isnull(SUM(cpl.balanceffbbfqty), 0) toyear_balanceffbbfqty,
                                       Isnull(SUM(cpl.FFBReceived ), 0) today_FFBReceivedYTD
                                FROM   production.cpoproductionlog cpl
                                       INNER JOIN general.cropyield gcy
                                         ON cpl.cropyieldid = gcy.cropyieldid
                                            AND gcy.cropyieldcode = 'CPO'
                                WHERE  cpl.estateid = @EstateID
                                       AND cpl.productionlogdate BETWEEN @YearFromDate AND @Date) x)AS t3
               ON t1.rc = t3.rc
             LEFT JOIN (SELECT today_cpoqtytoday,
                               today_oer,
                               month_cpoqty,
                               
                               year_cpoqty,
                               Row_number() OVER(ORDER BY today_cpoqtytoday DESC) AS rc
                        FROM
                       --CPO Produced  
                       (SELECT Isnull(SUM(cpo.qtytoday), 0)       today_cpoqtytoday,
                               Isnull(SUM(cpl.oer), 0)            today_oer,
                               Isnull((SELECT Isnull(SUM(cpo.qtytoday), 0) cpoqty_month
								FROM   production.cpoproduction cpo
								INNER JOIN general.cropyield gcy ON cpo.cropyieldid = gcy.cropyieldid AND gcy.cropyieldcode = 'CPO'
								INNER JOIN production.cpoproductionlog cpl ON cpo.cpoproductiondate = cpl.productionlogdate AND CPO.CropYieldID = cpl.CropYieldID 
								WHERE  cpo.estateid = @EstateID AND cpo.cpoproductiondate BETWEEN @MonthFromDate AND @Date), 0) month_cpoqty,
                               Isnull(SUM(cpo.qtyyeartodate), 0)  year_cpoqty
                        FROM   production.cpoproduction cpo
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'CPO'
                               INNER JOIN production.cpoproductionlog cpl
                                 ON cpo.cpoproductiondate = cpl.productionlogdate
                                 AND CPO.CropYieldID = cpl.CropYieldID 
                                 WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate = @Date) x)AS t4
               ON t1.rc = t4.rc
             /*
             LEFT JOIN
             ---- Changed by kumar
             (SELECT tomonth_oer,
                     tomonth_cpoqtytoday,
                     Row_number() OVER(ORDER BY tomonth_oer DESC) AS rc
              FROM   (SELECT Isnull((cpo.qtymonthtodate), 0) tomonth_cpoqtytoday,
                             Isnull((cpl.oer), 0)            tomonth_oer
                      FROM   production.cpoproduction cpo
                             INNER JOIN general.cropyield gcy
                               ON cpo.cropyieldid = gcy.cropyieldid
                                  AND gcy.cropyieldcode = 'CPO'
                             INNER JOIN production.cpoproductionlog cpl
                               ON cpo.cpoproductiondate = cpl.productionlogdate
                               AND CPO.CropYieldID = cpl.CropYieldID 
                      WHERE  cpo.estateid = @EstateID
                             AND cpo.cpoproductiondate = @Date) x)AS t5
               ON t1.rc = t5.rc
               
               */
             LEFT JOIN (SELECT toyear_oer,
                               toyear_cpoqtytoday,
                               Row_number() OVER(ORDER BY toyear_oer DESC) AS rc
                        FROM
                       ---- Changed by kumar
                       (SELECT Isnull((cpo.qtyyeartodate), 0) toyear_cpoqtytoday,
                               Isnull((cpl.oer), 0)           toyear_oer
                        FROM   production.cpoproduction cpo
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'CPO'
                               INNER JOIN production.cpoproductionlog cpl
                                 ON cpo.cpoproductiondate = cpl.productionlogdate
                                 AND CPO.CropYieldID = cpl.CropYieldID 
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate = @Date) x)AS t6
               ON t1.rc = t6.rc
             LEFT JOIN (SELECT today_kernelqtytoday,
                               today_ker,
                               Row_number() OVER(ORDER BY today_kernelqtytoday DESC) AS rc
                        FROM
                       --Kernel Produced
                       (SELECT Isnull(SUM(cpo.qtytoday), 0) today_kernelqtytoday,
                        Isnull(SUM(cpo.qtytoday), 0) / nullif(SUM(cpl.FFBProcessedACT), 1) * 100 today_ker
                               
                        FROM   production.cpoproduction cpo
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'Kernel'
                               INNER JOIN production.cpoproductionlog cpl
                                 ON cpo.cpoproductiondate = cpl.productionlogdate
                                -- AND CPO.CropYieldID = cpl.CropYieldID 
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate = @Date) x)AS t7
               ON t1.rc = t7.rc
             LEFT JOIN (SELECT 
                               tomonth_kernelqtytoday,
                               Row_number() OVER(ORDER BY tomonth_kernelqtytoday DESC) AS rc
                        FROM
                       ---- Changed by kumar
                       (SELECT Isnull((sum(cpo.QtyToday)), 0) tomonth_kernelqtytoday
                        FROM   production.cpoproduction cpo
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'Kernel'
                               INNER JOIN production.cpoproductionlog cpl
                                 ON cpo.cpoproductiondate = cpl.productionlogdate
                              --   AND CPO.CropYieldID = cpl.CropYieldID 
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate BETWEEN @dtFrom AND @Date) x)AS t8
               ON t1.rc = t8.rc
             LEFT JOIN (SELECT toyear_ker,
                               toyear_kernelqtytoday,
                               Row_number() OVER(ORDER BY toyear_ker DESC) AS rc
                        FROM
                       ---- Changed by kumar
                       (SELECT Isnull((cpo.qtyyeartodate), 0) toyear_kernelqtytoday,
                               Isnull((cpl.ker), 0)           toyear_ker
                        FROM   production.cpoproduction cpo
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'Kernel'
                               INNER JOIN production.cpoproductionlog cpl
                                 ON cpo.cpoproductiondate = cpl.productionlogdate
                               --  AND CPO.CropYieldID = cpl.CropYieldID 
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate = @Date) x)AS t9
               ON t1.rc = t9.rc
             LEFT JOIN (SELECT today_cpoqualityffap,
                               today_cpoqualitymoisturep,
                               today_cpoqualitydirtp,
                               today_cpoqualityffapmtd,
                               Row_number() OVER(ORDER BY today_cpoqualityffap DESC) AS rc
                        FROM
                       --CPO Quality  
                       (SELECT Isnull((la.cpoproductionffap), 0)      today_cpoqualityffap,
                               Isnull((la.cpoproductionmoisturep), 0) today_cpoqualitymoisturep,
                               Isnull((la.cpoproductiondirtp), 0)     today_cpoqualitydirtp,
                               Isnull((la . CPOProductionFFAPMTD ), 0)  today_cpoqualityffapmtd
                               
                        FROM   production.laboratoryanalysis la
                        WHERE  la.estateid = @EstateID
                               AND la.labanalysisdate = @Date) x)AS t10
               ON t1.rc = t10.rc
             LEFT JOIN (SELECT today_kernelqualitybrokenkernel,
                               today_kernelqualitymoisturep,
                               today_kernelqualitydirtp,
                               Row_number() OVER(ORDER BY today_kernelqualitybrokenkernel DESC) AS rc
                        FROM
                       ----Kernel Quality
                       (SELECT Isnull((la.kerproductionbrokenkernel), 0) today_kernelqualitybrokenkernel,
                               Isnull((la.kerproductionmoisturep), 0)    today_kernelqualitymoisturep,
                               Isnull((la.kerproductiondirtp), 0)        today_kernelqualitydirtp
                        FROM   production.laboratoryanalysis la
                        WHERE  la.estateid = @EstateID
                               AND la.labanalysisdate = @Date) x)AS t13
               ON t1.rc = t13.rc
             LEFT JOIN (SELECT today_ffb,
                               Row_number() OVER(ORDER BY today_ffb DESC) AS rc
                        FROM
                       ----FFB
                       (SELECT Isnull(SUM(wio.netweight / 1000), 0) AS today_ffb
                        FROM   weighbridge.wbweighinginout wio
                               INNER JOIN weighbridge.wbproductmaster wpm
                                 ON wio.productid = wpm.productid
                        WHERE  wio.estateid = @EstateID
                               AND wpm.productdescp = 'FFB'
                               AND wio.weighingdate = @Date
                               AND wio.estateid = @EstateID) x)AS t16
               ON t1.rc = t16.rc
             LEFT JOIN (SELECT tomonth_ffb,
                               Row_number() OVER(ORDER BY tomonth_ffb DESC) AS rc
                        FROM   (SELECT Isnull(SUM(wio.netweight / 1000), 0) AS tomonth_ffb
                                FROM   weighbridge.wbweighinginout wio
                                       INNER JOIN weighbridge.wbproductmaster wpm
                                         ON wio.productid = wpm.productid
                                WHERE  wio.estateid = @EstateID
                                       AND wpm.productdescp = 'FFB'
                                       AND wio.weighingdate BETWEEN @MonthFromDate AND @Date) x)AS t17
               ON t1.rc = t17.rc
             LEFT JOIN (SELECT toyear_ffb,
                               Row_number() OVER(ORDER BY toyear_ffb DESC) AS rc
                        FROM   (SELECT Isnull(SUM(wio.netweight / 1000), 0) AS toyear_ffb
                                FROM   weighbridge.wbweighinginout wio
                                       INNER JOIN weighbridge.wbproductmaster wpm
                                         ON wio.productid = wpm.productid
                                WHERE  wio.estateid = @EstateID
                                       AND wpm.productdescp = 'FFB'
                                       AND wio.weighingdate BETWEEN @YearFromDate AND @Date) x)AS t18
               ON t1.rc = t18.rc
               
               LEFT JOIN (SELECT today_transcpo,
                               Row_number() OVER(ORDER BY today_transcpo DESC) AS rc
                        FROM
                       ----Transhipment  CPO
                       (SELECT Isnull(SUM(cpt.qty), 0) today_transcpo 
                        FROM   production.cpoproductiontranshipcpo cpt
                               INNER JOIN production.cpoproduction cpo 
                                 ON cpt.TranshipDate  = cpo.CPOProductionDate 
                                 AND CPO.CropYieldID = cpt.CropYieldID 
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'CPO'
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate = @Date) x)AS t19 
						ON t1.rc = t19.rc
               
             LEFT JOIN (SELECT MTD_transcpo,
                               Row_number() OVER(ORDER BY MTD_transcpo DESC) AS rc
                        FROM
                       ----Transhipment  CPO
                       (SELECT Isnull(SUM(cpt.qty), 0) MTD_transcpo 
                        FROM   production.cpoproductiontranshipcpo cpt
                               INNER JOIN production.cpoproduction cpo
                                 on cpt.TranshipDate between @dtFrom and @Date 
                                 AND CPO.CropYieldID = cpt.CropYieldID 
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'CPO'
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate = @Date) x)AS t199 
                               -- Do not use between condition (Results Wrong - Pls Investigate)
                               -- AND cpo.cpoproductiondate between @dtFrom and @Date) x)AS t199 
						ON t1.rc = t199.rc 
						
             LEFT JOIN (SELECT today_transkcp,
                               Row_number() OVER(ORDER BY today_transkcp DESC) AS rc 
                        FROM 
                       ----Kernel Transferred to KCP
                       (SELECT Isnull(SUM(cpt .qty), 0) today_transkcp 
                        FROM production.cpoproductiontranshipcpo cpt 
                               INNER JOIN production.cpoproduction cpo 
                                 ON cpt .TranshipDate  = cpo.CPOProductionDate 
                                  AND CPO.CropYieldID = cpt.CropYieldID 
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'Kernel'
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate = @Date) x)AS t20
               ON t1.rc = t20.rc
               
                LEFT JOIN (SELECT MTD_transKernel,
                               Row_number() OVER(ORDER BY MTD_transKernel DESC) AS rc
                        FROM
                       ----Kernel Transferred to KCP
                       (SELECT Isnull( SUM(cpt.qty),0)  MTD_transKernel 
                                           
                        FROM   production.cpoproductiontranshipcpo cpt
                               INNER JOIN production.cpoproduction cpo
                                 ON cpt .TranshipDate  = cpo.CPOProductionDate 
                                  AND CPO.CropYieldID = cpt.CropYieldID 
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'Kernel'
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate between @dtFrom and @Date) x)AS t200
               ON t1.rc = t200.rc
               
              
             LEFT JOIN (SELECT SUM(cps.currentreading) AS laststockcpo, Row_number() OVER(ORDER BY SUM(cps.currentreading) DESC) AS rc
						FROM   production.cpoproductionstockcpo cps 
						INNER JOIN production.tankmaster ptm ON cps.tankid = ptm.tankid
						INNER JOIN production.cpoproduction cpo ON cps.productionid = cpo.productionid
						INNER JOIN general.cropyield gcy ON cpo.cropyieldid = gcy.cropyieldid AND gcy.cropyieldcode = 'CPO'
						INNER JOIN (
						SELECT ptm.TankID, MAX(cpo.cpoproductiondate) LastReadingDate
						FROM production.cpoproductionstockcpo cps
						INNER JOIN production.tankmaster ptm ON cps.tankid = ptm.tankid
						INNER JOIN production.cpoproduction cpo ON cps.productionid = cpo.productionid
                        WHERE  cpo.estateid = @EstateID AND cpo.cpoproductiondate <= DATEAdd(Day,-1,@Date )  
                        GROUP BY ptm.TankID )  tbLR ON cps.TankID = tbLR.TankID AND cpo.CPOProductionDate = tbLR.LastReadingDate) AS t21
               ON t1.rc = t21.rc
                            LEFT JOIN (SELECT lastLoadcpo,
                               Row_number() OVER(ORDER BY lastLoadcpo DESC) AS rc
                        FROM
                       ----CPO Stocks, Last Stock  AS lastLoadcpo
                                               
                       (SELECT Isnull(SUM(cps.PrevDateQty ), 0) AS lastLoadcpo 
                        FROM   production.CPOProductionLoad  cps
                               INNER JOIN production.cpoproduction cpo
                                 ON cps.productionid = cpo.productionid
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'CPO'
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate = @Date                                         
                                                     
                               ) x)AS K21
               ON t1.rc = K21.rc
                LEFT JOIN (SELECT lastLoadcpolast,
                               Row_number() OVER(ORDER BY lastLoadcpolast DESC) AS rc
                        FROM
                       ----CPO Stocks, Last Stock  AS lastLoadcpo
                                               
                       (SELECT Isnull(SUM(cps.CurrentQty  ), 0) AS lastLoadcpolast 
                        FROM   production.CPOProductionLoad  cps
                               INNER JOIN production.cpoproduction cpo
                                 ON cps.productionid = cpo.productionid
                               INNER JOIN general.cropyield gcy
                                 ON cpo.cropyieldid = gcy.cropyieldid
                                    AND gcy.cropyieldcode = 'CPO'
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.cpoproductiondate = DATEAdd(Day,-1,@Date )                                        
                               
                               ) x)AS K22
               ON t1.rc = K22.rc
             
             LEFT JOIN (SELECT laststockkernel,
                               Row_number() OVER(ORDER BY laststockkernel DESC) AS rc
                        FROM
                        (SELECT
						 Isnull(sum(cps.currentreading), 0)    AS laststockkernel
				  FROM   production.cpoproductionstockcpo cps
						 INNER JOIN production.kernelstorage pks ON cps.kernelstorageid = pks.kernelstorageid
						 INNER JOIN production.cpoproduction cpo ON cps.productionid = cpo.productionid
						 INNER JOIN general.cropyield gcy ON cpo.cropyieldid = gcy.cropyieldid AND gcy.cropyieldcode = 'Kernel'
						 INNER JOIN (
			SELECT pks.KernelStorageID, MAX(cpo.cpoproductiondate) LastReadingDate
			FROM production.cpoproductionstockcpo cps
			INNER JOIN production.kernelstorage pks ON cps.kernelstorageid = pks.kernelstorageid
			INNER JOIN production.cpoproduction cpo ON cps.productionid = cpo.productionid
			INNER JOIN general.cropyield gcy ON cpo.cropyieldid = gcy.cropyieldid AND gcy.cropyieldcode = 'Kernel'
			WHERE  cpo.estateid = @EstateID AND cpo.cpoproductiondate <= DATEAdd(Day,-1,@Date )
			GROUP BY pks.KernelStorageID ) tblLR ON cps.KernelStorageID = tblLR.KernelStorageID AND cpo.CPOProductionDate = tblLR.LastReadingDate
			) x)AS t22
            ON t1.rc = t22.rc
             
             LEFT JOIN (SELECT Substring(CONVERT(VARCHAR, starttime, 108), 1, 5) AS starttime,
                               Substring(CONVERT(VARCHAR, endtime, 108), 1, 5)   AS stoptime,
                               totalhours                                        AS totaltime,
                               Row_number() OVER(ORDER BY starttime DESC)        AS rc --SUBSTRING(CONVERT(VARCHAR ,DATEADD(SS, (DATEDIFF (SS ,StartTime ,EndTime)),'01-01-2009 00:00:00' ),108), 1, 5) AS TotalTime, ROW_NUMBER() OVER(ORDER BY StartTime DESC) as RC
                        FROM   (SELECT ( CASE
                                           WHEN cps.shift1 IS NOT NULL THEN cps.starttime1
                                           WHEN ( cps.shift1 IS NULL
                                                  AND cps.shift2 IS NOT NULL ) THEN cps.starttime2
                                           WHEN ( cps.shift1 IS NULL
                                                  AND cps.shift2 IS NULL
                                                  AND cps.shift3 IS NOT NULL ) THEN cps.starttime3
                                         END ) AS starttime,
                                       ( CASE
                                           WHEN cps.shift3 IS NOT NULL THEN cps.endtime3
                                           WHEN ( cps.shift3 IS NULL
                                                  AND cps.shift2 IS NOT NULL ) THEN cps.endtime2
                                           WHEN ( cps.shift3 IS NULL
                                                  AND cps.shift2 IS NULL
                                                  AND cps.shift1 IS NOT NULL ) THEN cps.endtime1
                                         END ) AS endtime,
                                       cpl.totalhours
                                FROM   production.cpoproductionlogshifts cps
                                       INNER JOIN production.cpoproductionlog cpl
                                         ON cps.cpoproductionlogid = cpl.cpoproductionlogid
                                WHERE  cpl.estateid = @EstateID
                                       AND cpl.productionlogdate = @Date)AS cpls)AS t23
               ON t1.rc = t23.rc
             LEFT JOIN (SELECT today_mechanicalbd,
                               today_electricalbd,
                               today_processingbd,
                               toMonth_mechanicalbd,
                               toMonth_electricalbd,
                               toMonth_processingbd,
                               toYear_mechanicalbd,
                               toYear_electricalbd,
                               toYear_processingbd,
                               MonthToDateHrs,
                               YearToDateHrs,
                               Row_number() OVER(ORDER BY today_mechanicalbd DESC) AS rc --Today_EffectiveProcessingHours, Today_Throughput, 
                        FROM
                       ----Mechanical Break Down    
                       ----Electrical Break Down    
                       ----Processing Break Down      
                       (SELECT REPLACE(Isnull(mechanicalbd, 00.00), '.', ':') AS today_mechanicalbd,
                               REPLACE(Isnull(electricalbd, 00.00), '.', ':') AS today_electricalbd,
                               REPLACE(Isnull(processingbd, 00.00), '.', ':') AS today_processingbd,  
                               REPLACE(Isnull(MechanicalBDMTD , 00.00), '.', ':') AS toMonth_mechanicalbd,
                               REPLACE(Isnull(electricalbdMTD, 00.00), '.', ':') AS toMonth_electricalbd,
                               REPLACE(Isnull(processingbdMTD, 00.00), '.', ':') AS toMonth_processingbd ,
                               REPLACE(Isnull(MechanicalBDYTD, 00.00), '.', ':') AS toYear_mechanicalbd ,
                               REPLACE(Isnull(ElectricalBDYTD, 00.00), '.', ':') AS toYear_electricalbd ,
                               REPLACE(Isnull(ProcessingBDYTD, 00.00), '.', ':') AS toYear_processingbd ,
                               REPLACE(Isnull(MonthToDateHrs, 00.00), '.', ':') AS MonthToDateHrs ,
                               REPLACE(Isnull(YearToDateHrs, 00.00), '.', ':') AS YearToDateHrs   
                                                       
                        FROM   production.cpoproductionlog cpl
                        WHERE  cpl.estateid = @EstateID
                               AND cpl.productionlogdate = @Date)x)AS t24
               ON t1.rc = t24.rc
             LEFT JOIN (SELECT REPLACE(Isnull(tomonth_mechanicalbd, 00.00), '.', ':') AS tomonth_mechanicalbd,
                               REPLACE(Isnull(tomonth_electricalbd, 00.00), '.', ':') AS tomonth_electricalbd,
                               REPLACE(Isnull(tomonth_processingbd, 00.00), '.', ':') AS tomonth_processingbd,
                               Row_number() OVER(ORDER BY tomonth_mechanicalbd DESC)  AS rc --Today_EffectiveProcessingHours, Today_Throughput, 
                        FROM   (SELECT ( CONVERT(NVARCHAR, (t.mechanicalbd_hrs + t.mechanicalbd_hoursfrommunite)) + ':' + RIGHT('0' + CONVERT(NVARCHAR, (CASE WHEN (t.mechanicalbd_hoursfrommunite > 0) THEN (((t.mechanicalbd_mins/60) - t.mechanicalbd_hoursfrommunite) * 60) ELSE mechanicalbd_mins END)), 2) ) AS tomonth_mechanicalbd,
                                       CONVERT(NVARCHAR, (t.electricalbd_hrs + t.electricalbd_hoursfrommunite)) + ':' + RIGHT('0' + CONVERT(NVARCHAR, (CASE WHEN (t.electricalbd_hoursfrommunite > 0) THEN (((t.electricalbd_mins/60) - t.electricalbd_hoursfrommunite) * 60) ELSE electricalbd_mins END)), 2)     AS tomonth_electricalbd,
                                       CONVERT(NVARCHAR, (t.processingbd_hrs + t.processingbd_hoursfrommunite)) + ':' + RIGHT('0' + CONVERT(NVARCHAR, (CASE WHEN (t.processingbd_hoursfrommunite > 0) THEN (((t.processingbd_mins/60) - t.processingbd_hoursfrommunite) * 60) ELSE processingbd_mins END)), 2)     AS tomonth_processingbd
                                FROM   (SELECT SUM(CAST(Substring(Isnull(CAST(mechanicalbd AS NVARCHAR), '00.00'), 0, Charindex(':', Isnull(CAST(mechanicalbd AS NVARCHAR), '00.00'))) AS INT))                                                                                  AS mechanicalbd_hrs,
                                               CONVERT(FLOAT, Floor((SUM(CAST(Substring(Isnull(CAST(mechanicalbd AS NVARCHAR), '00.00'), Charindex(':', Isnull(CAST(mechanicalbd AS NVARCHAR), '00.00'))+1, Len(Isnull(CAST(mechanicalbd AS NVARCHAR), '00.00'))) AS INT)))/60)) AS mechanicalbd_hoursfrommunite,
                                               CONVERT(FLOAT, (SUM(CAST(Substring(Isnull(CAST(mechanicalbd AS NVARCHAR), '00.00'), Charindex(':', Isnull(CAST(mechanicalbd AS NVARCHAR), '00.00'))+1, Len(Isnull(CAST(mechanicalbd AS NVARCHAR), '00.00'))) AS INT))))           AS mechanicalbd_mins,
                                               SUM(CAST(Substring(Isnull(CAST(electricalbd AS NVARCHAR), '00.00'), 0, Charindex(':', Isnull(CAST(electricalbd AS NVARCHAR), '00.00'))) AS INT))                                                                                  AS electricalbd_hrs,
                                               CONVERT(FLOAT, Floor((SUM(CAST(Substring(Isnull(CAST(electricalbd AS NVARCHAR), '00.00'), Charindex(':', Isnull(CAST(electricalbd AS NVARCHAR), '00.00'))+1, Len(Isnull(CAST(electricalbd AS NVARCHAR), '00.00'))) AS INT)))/60)) AS electricalbd_hoursfrommunite,
                                               CONVERT(FLOAT, (SUM(CAST(Substring(Isnull(CAST(electricalbd AS NVARCHAR), '00.00'), Charindex(':', Isnull(CAST(electricalbd AS NVARCHAR), '00.00'))+1, Len(Isnull(CAST(electricalbd AS NVARCHAR), '00.00'))) AS INT))))           AS electricalbd_mins,
                                               SUM(CAST(Substring(Isnull(CAST(processingbd AS NVARCHAR), '00.00'), 0, Charindex(':', Isnull(CAST(processingbd AS NVARCHAR), '00.00'))) AS INT))                                                                                  AS processingbd_hrs,
                                               CONVERT(FLOAT, Floor((SUM(CAST(Substring(Isnull(CAST(processingbd AS NVARCHAR), '00.00'), Charindex(':', Isnull(CAST(processingbd AS NVARCHAR), '00.00'))+1, Len(Isnull(CAST(processingbd AS NVARCHAR), '00.00'))) AS INT)))/60)) AS processingbd_hoursfrommunite,
                                               CONVERT(FLOAT, (SUM(CAST(Substring(Isnull(CAST(processingbd AS NVARCHAR), '00.00'), Charindex(':', Isnull(CAST(processingbd AS NVARCHAR), '00.00'))+1, Len(Isnull(CAST(processingbd AS NVARCHAR), '00.00'))) AS INT))))           AS processingbd_mins
                                        FROM   production.cpoproductionlog cpl
                                        WHERE  cpl.estateid = @EstateID
                                               AND cpl.productionlogdate BETWEEN @MonthFromDate AND @Date) t) x)AS t25
               ON t1.rc = t25.rc
             LEFT JOIN (SELECT Isnull(totalpresshours, '00:00')                 AS totalpresshours,
                               Row_number() OVER(ORDER BY totalpresshours DESC) AS rc
                        FROM
                       ----Total Press Hours  
                       (SELECT ( CONVERT(NVARCHAR, (t.ophrs_hrs + t.ophrs_hoursfrommunite)) + ':' + RIGHT('0' + CONVERT(NVARCHAR, (CASE WHEN (t.ophrs_hoursfrommunite > 0) THEN (((t.ophrs_mins/60) - t.ophrs_hoursfrommunite) * 60) ELSE ophrs_mins END)), 2) ) AS totalpresshours
                        FROM   (SELECT SUM(CAST(Substring(Isnull(Isnull(CAST(cpp.ophrs AS NVARCHAR), '00.00'), '00.00'), 0, Charindex(':', Isnull(CAST(cpp.ophrs AS NVARCHAR), '00.00'))) AS INT))                                                              AS ophrs_hrs,
                                       CONVERT(FLOAT, Floor((SUM(CAST(Substring(Isnull(CAST(cpp.ophrs AS NVARCHAR), '00.00'), Charindex(':', Isnull(CAST(cpp.ophrs AS NVARCHAR), '00.00'))+1, Len(Isnull(CAST(cpp.ophrs AS NVARCHAR), '00.00'))) AS INT)))/60)) AS ophrs_hoursfrommunite,
                                       CONVERT(FLOAT, (SUM(CAST(Substring(Isnull(CAST(cpp.ophrs AS NVARCHAR), '00.00'), Charindex(':', Isnull(CAST(cpp.ophrs AS NVARCHAR), '00.00'))+1, Len(Isnull(CAST(cpp.ophrs AS NVARCHAR), '00.00'))) AS INT))))           AS ophrs_mins
                                FROM   production.cpoproductionlogpress cpp
                                       INNER JOIN production.cpoproductionlog cpl
                                         ON cpp.cpoproductionlogid = cpl.cpoproductionlogid
                                WHERE  cpl.estateid = @EstateID
                                       AND cpl.productionlogdate = @Date) t) x)AS t26
               ON t1.rc = t26.rc
             LEFT JOIN (SELECT remarks,
                               Row_number() OVER(ORDER BY remarks DESC) AS rc
                        FROM
                       --Remarks
                       (SELECT DISTINCT Isnull(cpl.remarks,'' ) remarks
                        FROM   production.cpoproductionlog cpl
                               WHERE  cpl.estateid = @EstateID
                               AND cpl.productionlogdate = @Date) x)AS t27
               ON t1.rc = t27.rc
             LEFT JOIN (SELECT nounitsoperation,
                               Row_number() OVER(ORDER BY nounitsoperation DESC) AS rc
                        FROM
                       --Number of Units in Operation
                       (SELECT COUNT(cpl.machineid) AS nounitsoperation
                        FROM   production.cpoproductionlogpress cpl
                               INNER JOIN production.machinerymaster pmm
                                 ON cpl.machineid = pmm.machineid
                               INNER JOIN production.cpoproductionlog cpo
                                 ON cpo.cpoproductionlogid = cpl.cpoproductionlogid
                        WHERE  cpo.estateid = @EstateID
                               AND cpo.productionlogdate = @Date) x)AS t28
               ON t1.rc = t28.rc

-- ### TABLE 1 ###


      SELECT a1.name,
             Isnull(a1.today_netweight, 0)   AS today_netweight,
             a1.notrips,
             Isnull(a2.tomonth_netweight, 0) AS tomonth_netweight,
             Isnull(a3.toyear_netweight, 0)  AS toyear_netweight
      FROM   (SELECT name,
                     today_netweight,
                     notrips,
                     Row_number() OVER(ORDER BY(name)) AS rc
              FROM   (SELECT wbs.name,
                             Isnull(SUM(wio.netweight / 1000), 0) AS today_netweight,
                             COUNT(*)                             AS notrips
                      FROM   weighbridge.wbweighinginout wio
                             INNER JOIN weighbridge.wbsupplier wbs
                               ON wio.suppliercustid = wbs.suppliercustid
                             INNER JOIN weighbridge.wbproductmaster wpm
                               ON wio.productid = wpm.productid
                      WHERE  wio.weighingdate = @Date
                             AND wio.estateid = @EstateID
                             AND wbs.ownoroutsideestate = '1'
                             AND wpm.productdescp = 'FFB'
                      GROUP  BY wbs.name) x) AS a1
             LEFT JOIN (SELECT name,
                               tomonth_netweight,
                               Row_number() OVER(ORDER BY(name)) AS rc
                        FROM   (SELECT wbs.name,
                                       Isnull(SUM(wio.netweight / 1000), 0) AS tomonth_netweight
                                FROM   weighbridge.wbweighinginout wio
                                       INNER JOIN weighbridge.wbsupplier wbs
                                         ON wio.suppliercustid = wbs.suppliercustid
                                       INNER JOIN weighbridge.wbproductmaster wpm
                                         ON wio.productid = wpm.productid
                                WHERE  wio.estateid = @EstateID
                                       AND wio.weighingdate BETWEEN @MonthFromDate AND @Date
                                       AND wbs.ownoroutsideestate = '1'
                                       AND wpm.productdescp = 'FFB'
                                GROUP  BY wbs.name) x) AS a2
               ON a1.rc = a2.rc
             LEFT JOIN (SELECT name,
                               toyear_netweight,
                               Row_number() OVER(ORDER BY name DESC) AS rc
                        FROM   (SELECT wbs.name,
                                       Isnull(SUM(wio.netweight / 1000), 0) AS toyear_netweight
                                FROM   weighbridge.wbweighinginout wio
                                       INNER JOIN weighbridge.wbsupplier wbs
                                         ON wio.suppliercustid = wbs.suppliercustid
                                       INNER JOIN weighbridge.wbproductmaster wpm
                                         ON wio.productid = wpm.productid
                                WHERE  wio.estateid = @EstateID
                                       AND wio.weighingdate BETWEEN @YearFromDate AND @Date
                                       AND wbs.ownoroutsideestate = '1'
                                       AND wpm.productdescp = 'FFB'
                                GROUP  BY wbs.name) x) AS a3
               ON a1.rc = a3.rc

-- ### TABLE 2 ###

      SELECT a1.name,
             Isnull(a1.today_netweight, 0)   AS today_netweight,
             a1.notrips,
             Isnull(a2.tomonth_netweight, 0) AS tomonth_netweight,
             Isnull(a3.toyear_netweight, 0)  AS toyear_netweight
      FROM   (SELECT name,
                     today_netweight,
                     notrips,
                     Row_number() OVER(ORDER BY(name)) AS rc
              FROM   (SELECT wbs.name,
                             Isnull(SUM(wio.netweight / 1000), 0) AS today_netweight,
                             COUNT(*)                             AS notrips
                      FROM   weighbridge.wbweighinginout wio
                             INNER JOIN weighbridge.wbsupplier wbs
                               ON wio.suppliercustid = wbs.suppliercustid
                             INNER JOIN weighbridge.wbproductmaster wpm
                               ON wio.productid = wpm.productid
                      WHERE  wio.weighingdate = @Date
                             AND wio.estateid = @EstateID
                             AND wbs.ownoroutsideestate = '4'
                             AND wpm.productdescp = 'FFB'
                             --AND wpm.productdescp = 'XXXXXXX'
                             -- PALANI / ENGER 'XXXXXXX' was given to supress the records from this TABLE # 2
                      GROUP  BY wbs.name) x) AS a1
             LEFT JOIN (SELECT name,
                               tomonth_netweight,
                               Row_number() OVER(ORDER BY(name)) AS rc
                        FROM   (SELECT wbs.name,
                                       Isnull(SUM(wio.netweight / 1000), 0) AS tomonth_netweight
                                FROM   weighbridge.wbweighinginout wio
                                       INNER JOIN weighbridge.wbsupplier wbs
                                         ON wio.suppliercustid = wbs.suppliercustid
                                       INNER JOIN weighbridge.wbproductmaster wpm
                                         ON wio.productid = wpm.productid
                                WHERE  wio.estateid = @EstateID
                                       AND wio.weighingdate BETWEEN @MonthFromDate AND @Date
                                       AND wbs.ownoroutsideestate = '4'
                                       AND wpm.productdescp = 'FFB'
                                GROUP  BY wbs.name) x) AS a2
               ON a1.rc = a2.rc
             LEFT JOIN (SELECT name,
                               toyear_netweight,
                               Row_number() OVER(ORDER BY name DESC) AS rc
                        FROM   (SELECT wbs.name,
                                       Isnull(SUM(wio.netweight / 1000), 0) AS toyear_netweight
                                FROM   weighbridge.wbweighinginout wio
                                       INNER JOIN weighbridge.wbsupplier wbs
                                         ON wio.suppliercustid = wbs.suppliercustid
                                       INNER JOIN weighbridge.wbproductmaster wpm
                                         ON wio.productid = wpm.productid
                                WHERE  wio.estateid = @EstateID
                                       AND wio.weighingdate BETWEEN @YearFromDate AND @Date
                                       AND wbs.ownoroutsideestate = '4'
                                       AND wpm.productdescp = 'FFB'
                                GROUP  BY wbs.name) x) AS a3
               ON a1.rc = a3.rc

/*
-- ### TABLE 3 ###

       SELECT ( 'At ' + cll.descp )   AS location,
             Isnull(SUM(cpl.qty), 0) today_loadcpo 
      FROM   production.loadinglocation cll
             INNER JOIN production.cpoproductionloadingcpo cpl
               ON cpl.loadinglocationid = cll.loadinglocationid
             INNER JOIN production.cpoproduction cpo
               ON cpl.LoadingDate  = cpo.CPOProductionDate 
                AND CPO.CropYieldID = cpl.CropYieldID 
             INNER JOIN general.cropyield gcy
               ON cpo.cropyieldid = gcy.cropyieldid
                  AND gcy.cropyieldcode = 'CPO'
      WHERE  cpo.estateid = @EstateID
             AND cpo.cpoproductiondate = @Date
      GROUP  BY cll.descp

-- ### TABLE 4 ###
      
       SELECT ( 'At ' + cll.descp ) AS location,
             Isnull(SUM(cpl.qty ), 0) MTD_loadcpo 
      FROM   production.loadinglocation cll
             INNER JOIN production.cpoproductionloadingcpo cpl
               ON cpl.loadinglocationid = cll.loadinglocationid
             INNER JOIN production.cpoproduction cpo
               ON cpl.LoadingDate  = cpo.CPOProductionDate 
                AND CPO.CropYieldID = cpl.CropYieldID 
             INNER JOIN general.cropyield gcy
               ON cpo.cropyieldid = gcy.cropyieldid
                  AND gcy.cropyieldcode = 'CPO'
      WHERE  cpo.estateid = @EstateID
             AND cpo.cpoproductiondate  between @dtFrom and @Date
      GROUP  BY cll.descp
*/

-- ### TABLE 3 ###
	select case when (temp.location is null or temp.location != '') then temp1.location else temp.location end as Location,
	isnull(temp.today_loadcpo,0) as today_loadcpo,isnull(temp1.MTD_loadcpo,0) as MTD_loadcpo  from 
	(
       SELECT ( 'At ' + cll.descp )   AS location,
             Isnull(SUM(cpl.qty), 0) today_loadcpo 
      FROM   production.loadinglocation cll
             INNER JOIN production.cpoproductionloadingcpo cpl
               ON cpl.loadinglocationid = cll.loadinglocationid
             INNER JOIN production.cpoproduction cpo
               ON cpl.LoadingDate  = cpo.CPOProductionDate 
                AND CPO.CropYieldID = cpl.CropYieldID 
             INNER JOIN general.cropyield gcy
               ON cpo.cropyieldid = gcy.cropyieldid
                  AND gcy.cropyieldcode = 'CPO'
      WHERE  cpo.estateid = @EstateID
             AND cpo.cpoproductiondate = @Date
      GROUP  BY cll.descp) temp 
	full outer  join 
		  (SELECT ( 'At ' + cll.descp ) AS location,
				 Isnull(SUM(cpl.qty ), 0) MTD_loadcpo 
		  FROM   production.loadinglocation cll
				 INNER JOIN production.cpoproductionloadingcpo cpl
				   ON cpl.loadinglocationid = cll.loadinglocationid
				 INNER JOIN production.cpoproduction cpo
				   ON cpl.LoadingDate  = cpo.CPOProductionDate 
					AND CPO.CropYieldID = cpl.CropYieldID 
				 INNER JOIN general.cropyield gcy
				   ON cpo.cropyieldid = gcy.cropyieldid
					  AND gcy.cropyieldcode = 'CPO'
		  WHERE  cpo.estateid = @EstateID
				 AND cpo.cpoproductiondate  between @dtFrom and @Date
		  GROUP  BY cll.descp) temp1
	on (temp.location  = temp1.location)
      
      

-- TABLE 4 is Dummy & not really used inside the Front END
-- ### TABLE 4 ###
      
       SELECT ( 'At ' + cll.descp ) AS location,
             Isnull(SUM(cpl.qty ), 0) MTD_loadcpo 
      FROM   production.loadinglocation cll
             INNER JOIN production.cpoproductionloadingcpo cpl
               ON cpl.loadinglocationid = cll.loadinglocationid
             INNER JOIN production.cpoproduction cpo
               ON cpl.LoadingDate  = cpo.CPOProductionDate 
                AND CPO.CropYieldID = cpl.CropYieldID 
             INNER JOIN general.cropyield gcy
               ON cpo.cropyieldid = gcy.cropyieldid
                  AND gcy.cropyieldcode = 'CPO'
      WHERE  cpo.estateid = @EstateID
             AND cpo.cpoproductiondate  between @dtFrom and @Date
      GROUP  BY cll.descp

-- ### TABLE 5 ###
		/*
      SELECT ptm.tankno,
             Isnull(cps.currentreading, 0) AS currentreading
      FROM   production.cpoproductionstockcpo cps
             INNER JOIN production.tankmaster ptm
               ON cps.tankid = ptm.tankid
             INNER JOIN production.cpoproduction cpo
               ON cps.productionid = cpo.productionid
             INNER JOIN general.cropyield gcy
               ON cpo.cropyieldid = gcy.cropyieldid
                  AND gcy.cropyieldcode = 'CPO'
      WHERE  cpo.estateid = @EstateID AND cpo.cpoproductiondate = @Date
      */
      
		
		SELECT ptm.tankno, 
		Isnull(cps.currentreading, 0) AS currentreading,
		isnull(tblQuality.FFAP,0) AS FFAP,
		isnull(tblQuality.MoistureP, 0) AS MoistureP,
		isnull(tblQuality.DirtP,0) AS DirtP
		FROM   production.cpoproductionstockcpo cps 
		INNER JOIN production.tankmaster ptm ON cps.tankid = ptm.tankid
		INNER JOIN production.cpoproduction cpo ON cps.productionid = cpo.productionid
		INNER JOIN general.cropyield gcy ON cpo.cropyieldid = gcy.cropyieldid AND gcy.cropyieldcode = 'CPO'
		INNER JOIN (
		SELECT ptm.TankID, MAX(cpo.cpoproductiondate) LastReadingDate
		FROM production.cpoproductionstockcpo cps
		INNER JOIN production.tankmaster ptm ON cps.tankid = ptm.tankid
		INNER JOIN production.cpoproduction cpo ON cps.productionid = cpo.productionid
		WHERE  cpo.estateid = @EstateID AND cpo.cpoproductiondate <= @Date
		GROUP BY ptm.TankID ) tbLR ON cps.TankID = tbLR.TankID AND cpo.CPOProductionDate = tbLR.LastReadingDate
		LEFT JOIN (
			Select 
				P_LOQS.TankID ,
				P_LOQS.FFAP ,
				P_LOQS.MoistureP ,
				P_LOQS.DirtP
				from Production.LabOilQualityStorage P_LOQS
				INNER JOIN Production.LaboratoryAnalysis as P_LAB ON P_LAB.LabAnalysisID = P_LOQS.LabAnalysisID
				Where P_LOQS.EstateID = @EstateID AND P_LAB.LabAnalysisDate  = @Date AND P_LOQS.ProductType = 'CPO'
		) tblQuality ON tblQuality.TankID = tbLR.TankID
		ORDER BY ptm.tankno
		
		
		

-- ### TABLE 6 ###

      /*
      SELECT pks.code AS kernelname,
             Isnull(cps.currentreading, 0)    AS currentreading,
             Isnull(cps.MoistureP , 0)    AS moisterP,
             Isnull(cps.DirtP , 0)    AS DirtP
 
             
      FROM   production.cpoproductionstockcpo cps
             INNER JOIN production.kernelstorage pks
               ON cps.kernelstorageid = pks.kernelstorageid
             INNER JOIN production.cpoproduction cpo
               ON cps.productionid = cpo.productionid
             INNER JOIN general.cropyield gcy
               ON cpo.cropyieldid = gcy.cropyieldid
                  AND gcy.cropyieldcode = 'Kernel'
                  
      WHERE  cpo.estateid = @EstateID
             AND cpo.cpoproductiondate = @Date
      */
      SELECT pks.code AS kernelname,
             Isnull(cps.currentreading, 0)    AS currentreading,
             Isnull(cps.MoistureP , 0)    AS moisterP,
             Isnull(cps.DirtP , 0)    AS DirtP
      FROM   production.cpoproductionstockcpo cps
             INNER JOIN production.kernelstorage pks ON cps.kernelstorageid = pks.kernelstorageid
             INNER JOIN production.cpoproduction cpo ON cps.productionid = cpo.productionid
             INNER JOIN general.cropyield gcy ON cpo.cropyieldid = gcy.cropyieldid AND gcy.cropyieldcode = 'Kernel'
             INNER JOIN (
SELECT pks.KernelStorageID, MAX(cpo.cpoproductiondate) LastReadingDate
FROM production.cpoproductionstockcpo cps
INNER JOIN production.kernelstorage pks ON cps.kernelstorageid = pks.kernelstorageid
INNER JOIN production.cpoproduction cpo ON cps.productionid = cpo.productionid
INNER JOIN general.cropyield gcy ON cpo.cropyieldid = gcy.cropyieldid AND gcy.cropyieldcode = 'Kernel'
WHERE  cpo.estateid = @EstateID AND cpo.cpoproductiondate <= @Date
GROUP BY pks.KernelStorageID ) tblLR ON cps.KernelStorageID = tblLR.KernelStorageID AND cpo.CPOProductionDate = tblLR.LastReadingDate
ORDER BY pks.KernelStorageID

-- ### TABLE 7 ###

      SELECT cpl.stage,
             pmm.machinecode                            AS pressno,
             pmm.capacity,
             REPLACE(Isnull(cpl.ophrs, 0.00), '.', ':') AS operatinghours,
             REPLACE(cpl.screwage,'.',':') as screwage,
             cpl.screwstatus
      FROM   production.cpoproductionlogpress cpl
             INNER JOIN production.machinerymaster pmm
               ON cpl.machineid = pmm.machineid
             INNER JOIN production.cpoproductionlog cpo
               ON cpo.cpoproductionlogid = cpl.cpoproductionlogid
      WHERE  cpo.estateid = @EstateID
             AND cpo.productionlogdate = @Date
      ORDER  BY cpl.stage
       
-- ### TABLE 8 ###
       
             SELECT  LoadingLocationCode+' -'+Descp  as tankno ,
             Isnull(cps.CurrentQty , 0) AS currentreading
      FROM   production.CPOProductionLoad  cps
             INNER JOIN production.LoadingLocation  pLL
               ON cps.LoadingLocationID  = pLL.LoadingLocationID
             INNER JOIN production.cpoproduction cpo
               ON cps.productionid = cpo.productionid
             INNER JOIN general.cropyield gcy
               ON cpo.cropyieldid = gcy.cropyieldid
                  AND gcy.cropyieldcode = 'CPO'
      WHERE  cpo.estateid = @EstateID
             AND cpo.cpoproductiondate = @Date
       
-- ### TABLE 9 - RippleMill - Laboratory Data ###
	Select 
		LabEffRippleMillID as LabEffRippleMill,
		Line ,
		No,
		EfficiencyP,
		Equipment							
	from Production.LabEffRippleMill a
	INNER JOIN Production.LaboratoryAnalysis b ON a.LabAnalysisID = b.LabAnalysisID
	WHERE a.EstateID = @EstateID AND b.LabAnalysisDate = @Date
	ORDER BY [No],Line
 
-- ### TABLE 10 - KernelQuality - Laboratory Data ###
	Select 
				LabKERQualityID as LabKernelQtyStorageID,
				Line,
				Location ,
				MoistureP,
				DirtP,
				BrokenKernel						
				from Production.LabKernelQualityStorage a
				INNER JOIN Production.LaboratoryAnalysis b ON a.LabAnalysisID = b.LabAnalysisID
				WHERE a.EstateID = @EstateID AND b.LabAnalysisDate = @Date
				ORDER BY Location

-- ### TABLE 11 - LabKernel Losses - Laboratory Data ###
	Select 
				LabKernelLossesFFBID,
				Line ,
				isnull(LTDS1P,0) as LTDS1P,
				isnull(LTDS2P,0) as LTDS2P,
				isnull(LTDS3P,0) as LTDS3P,
				isnull(LTDS4P,0) as LTDS4P,
				FibreCycP,
				HydroCycP,
				FruitinEB						
				from Production.LabKernelLossesFFB a
				INNER JOIN Production.LaboratoryAnalysis b ON a.LabAnalysisID = b.LabAnalysisID
				WHERE a.EstateID = @EstateID AND b.LabAnalysisDate = @Date
				ORDER BY Line
				
-- ### TABLE 12 - Machine Operation Hours - Laboratory Data ###

	Select 
				P_MM .MachineCode +'-' + P_MM .MachineName as MachineName ,
				P_MM.Descp  ,
				P_MO.ProcessHours ,
				P_MO.NonProcessHours ,
				P_MO .TotalHours ,
				--P_MO .MonthToDateHrs ,
				monthToDate.MTD as MonthToDateHrs,
				P_MO .YeartoDateHrs 
			    from Production.MachineryOperation as P_MO
				INNER JOIN Production .MachineryMaster as P_MM ON P_MM .MachineID =P_MO .MachineID 
				INNER JOIN Production.LaboratoryAnalysis b ON P_MO.LabAnalysisID = b.LabAnalysisID
				INNER JOIN (
					Select 
					P_MO.MachineID  ,
					RTRIM(
						((SUM(CAST(SUBSTRING(P_MO .TotalHours, 0, CHARINDEX(':',P_MO .TotalHours)) as Integer) ) * 60) +
						SUM(CAST(SUBSTRING(P_MO .TotalHours, CHARINDEX(':',P_MO .TotalHours)+1, LEN(P_MO .TotalHours)) as Integer)))	/ 60
					) + ':' +
					RIGHT('0'+
					RTRIM(
						((SUM(CAST(SUBSTRING(P_MO .TotalHours, 0, CHARINDEX(':',P_MO .TotalHours)) as Integer) ) * 60) +
						SUM(CAST(SUBSTRING(P_MO .TotalHours, CHARINDEX(':',P_MO .TotalHours)+1, LEN(P_MO .TotalHours)) as Integer)))	% 60
					),2) as MTD
					from Production.MachineryOperation as P_MO
					INNER JOIN Production .MachineryMaster as P_MM ON P_MM .MachineID =P_MO .MachineID 
					INNER JOIN Production.LaboratoryAnalysis b ON P_MO.LabAnalysisID = b.LabAnalysisID
					Where P_MO.EstateID = @EstateID  AND b.LabAnalysisDate BETWEEN @dtFrom AND @Date 
					GROUP BY P_MO.MachineID
				) as monthToDate ON monthToDate.MachineID = P_MO.MachineID
				Where P_MO.EstateID = @EstateID  AND b.LabAnalysisDate = @Date
				ORDER BY P_MM.Descp
				
-- ### TABLE 13 - SOP Standards ----
	SELECT 
		GenEfficiencyRolex,
		GenEfficiencyRippleMill,
		KLFibreCyclone,
		KLLTDS1,
		KLLTDS2,
		KLLTDS3,
		KLLTDS4,
		KLHydrocyclone,
		QltFKDirt,
		QltFKMoisture,
		QltFKBrokenKernel,
		QltKADirt,
		QltKAMoisture,
		QltKABrokenKernel
		FROM Production.SOP
		WHERE EstateID = @EstateID
		
		
-- ### Table 14 - Shift Performance ----
SELECT
		Shift1,
		LorryProcessedEST1
		 ,CONVERT(VARCHAR(5),  StartTime1, 108) 	 as StartTime1
			  ,CONVERT(VARCHAR(5),  EndTime1, 108) 	 as EndTime1,
			  CONVERT(VARCHAR(5),  TotalBreakdown1, 108) 	 as TotalBreakdown1,
		Shift2,
		LorryProcessedEST2,
		CONVERT(VARCHAR(5),  StartTime2, 108) 	 as StartTime2
			  , CONVERT(VARCHAR(5),  EndTime2, 108) 	 as EndTime2,
			  CONVERT(VARCHAR(5),  TotalBreakdown2, 108) 	 as TotalBreakdown2,
		Shift3,
		LorryProcessedEST3,
			   CONVERT(VARCHAR(5),  StartTime3, 108) 	 as StartTime3
			  , CONVERT(VARCHAR(5),  EndTime3, 108) 	 as EndTime3,
			  CONVERT(VARCHAR(5),  TotalBreakdown3, 108) 	 as TotalBreakdown3
	From Production.CPOProductionLogShifts    as CPO_LogShift
	INNER JOIN Production.CPOProductionLog as CPO_Log ON CPO_LogShift.CPOProductionLogID =CPO_Log.CPOProductionLogID 
	WHERE  CPO_Log.estateid = @EstateID AND CPO_Log.productionlogdate = @Date
	
--Table 15 Writeoff
Select TM.TankNo,KS.Code as KernelStorage,Writeoff,Reason from Production.CPOProductionStockCPO SCPO
INNER JOIN Production.CPOProduction CPO ON CPO.ProductionID = SCPO.ProductionID
LEFT JOIN Production.TankMaster TM ON TM.TankID = SCPO.TankID
LEFT JOIN Production.KernelStorage KS ON KS.KernelStorageID = SCPO.KernelStorageID
LEFT JOIN General.CropYield CY ON CY.CropYieldID = CPO.CropYieldID
WHERE CPO.CPODate = @Date 
AND Writeoff > 0
AND CPO.CropYieldID <> 'M2'
  END
