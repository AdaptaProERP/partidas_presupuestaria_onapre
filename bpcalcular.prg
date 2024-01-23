// Programa   : BPCALCULAR
// Fecha/Hora : 27/02/2006 23:40:36
// Propósito  : Calcular Estado Situacional Presupuesto según Partidas
// Creado Por : Juan Navas
// Llamado por: REPORTE PPCPRESUPUESTARIO
// Aplicación : Presupuesto Administración Pública
// Tabla      : DPCTAPRESUP

#INCLUDE "DPXBASE.CH"
#include "DpxReport.ch"

PROCE MAIN(oGenRep,dDesde,dHasta,nMaxCol,cPicture,cTextT,cCecod,cCecoh,cCtaD,cCtaH)
   LOCAL aCtaBg:={}
   LOCAL nAt,nCol,nLen,aData:={},nField,aNew:={},lTotales:=.F.
   LOCAL aLenBg:={},cWhere:="",I,cSql,oTable,cCodCta:="",oCuentas,nRecCount,nLen0,nMaxNiv:=0,nNivel,nNivMax:=0
   LOCAL nPasCap:=0,bSkip,bRup,aCuentas:={},aData:={},aSaldos:={}
   LOCAL cPre,cCom,cEje,cPag,cWhereG:="",dFchIni:=oDp:dFchInicio,I
   LOCAL _PRESUP  :=0,_COMPRO  :=0,_EJECUT  :=0,_PAGADO  :=0
   LOCAL _COL     :=0,_TIPO    :=0,_NUM     :=0,_TITULO  :=0
   LOCAL _ASIENTO :=0,_NIVEL   :=0,_COL     :=0
   LOCAL nMtoCom  :=0,nMtoEje  :=0,nMtoPre  :=0,nMtoPag  :=0,oDatos,lBalIni
   LOCAL cExcluye:=[AND NOT (ASP_ORIGEN="INI" OR ASP_ORIGEN="FIN")]
   LOCAL nLenD,nLenH
   LOCAL cWhereB:=""
   LOCAL aActual:={"S"}

   cExcluye:=[ AND (1=1) ] // 02/08/2023 

   aCtaBg :={} // 22/01/2023

   IF !Empty(cCtaD)
      cWhereB:=GetWhereAnd("ASP_CODCTA",cCtaD,cCtaH)
   ENDIF

   cWhereB:=IF(Empty(cWhereB)," 1=1 ",cWhereB) // 22/01/2023

   DEFAULT dDesde  :=oDp:dFchInicio,;
           dHasta  :=oDp:dFecha,;
           nMaxCol :=7,;
           cPicture:="99,999,999,999,999.99",;
           cTextT  :="Total",;
           cCecod  :="",;
           cCecoh  :="",;
           cCtad   :="1",;
           cCtah   :="9"

// ? oGenRep,dDesde,dHasta,nMaxCol,cPicture,cTextT,cCecod,cCecoh,cCtaD,cCtaH,"oGenRep,dDesde,dHasta,nMaxCol,cPicture,cTextT,cCecod,cCecoh,cCtaD,cCtaH"

   DEFAULT oDp:lPrecontab:=.F. 

   nMaxCol :=CTOO(nMaxCol,"N")
   nMaxCol :=MIN(nMaxCol ,5+2)
   cPicture:=ALLTRIM(cPicture)
   cTextT  :=ALLTRIM(cTextT)+" "

   // 8/5/2021
   IF !Empty(cCtad)
      aCtaBg :={}
      cWhereG:=GetWhereAnd("ASP_CODCTA",cCtad,cCtah)

      cCtaD:=ALLTRIM(cCtaD)
      nLenD:=LEN(cCtaD)

      cCtaH:=ALLTRIM(cCtaH)
      nLenH:=LEN(cCtaH)
      cWhereG:=""
      cWhereG:=[LEFT(ASP_CODCTA,]+LSTR(nLenD)+[)]+GetWhere("=",cCtaD)

      IF !(cCtaD==cCtaH)

         cWhereG:=cWhereG+[ AND ]+;
                  [LEFT(ASP_CODCTA,]+LSTR(nLenH)+[)]+GetWhere("=",cCtaH)

      ENDIF

   ENDIF


  // Cuentas de BG
   // Cuentas de GP

   IF TYPE("RGO_C7")="U"
      PUBLICO("RGO_C7","")
   ENDIF

   cWhereG:=IIF(Empty(RGO_C7),""," ASP_CODSUC"+GetWhere("=",RGO_C7)+" AND ")+;
            "("+cWhereG+")"

 
   IF !Empty(cCecod) 	
 
      cWhereG:=cWhereG+ iif(Empty(cWhereG), " ", " AND ")+;
              GetWhereAnd("ASP_CENCOS",cCecod,cCecoh)
   ENDIF

   
   //  02/08/2023 Incidencia en Saldo Anterior PROGEL, Asiento de Cierre CTA: 3301002 cWhereG:="("+cWhereG+") AND (ASP_ACTUAL='S' OR ASP_ACTUAL='A' OR ASP_ACTUAL='C' OR ASP_ACTUAL=")"
   cWhereG:=" (1=1) " // 22/01/2023
   cWhereG:="("+cWhereG+") AND "+GetWhereOr("ASP_ACTUAL",aActual)

   IF !Empty(cCtad) .and. .f.
 
      cWhereG:=cWhereG+ iif(Empty(cWhereG), " ", " AND ")+;
              GetWhereAnd("ASP_CODCTA",cCtad,cCtah)

   ENDIF

   // 16/03/2022
   lBalIni:=EJECUTAR("ISBALANCEINI",dDesde)
   lBalIni:=.F.

   // JN 12/12/2022
   IF !lBalIni
     cWhereG:="("+cWhereG+")"+cExcluye
   ENDIF

   cPre:="SUM(IF("+GetWhereAnd("ASP_FECHA",dDesde,dHasta)+[ AND (ASP_TIPO="PI" OR ASP_TIPO="CR" OR ASP_TIPO="MO"), ASP_MONTO   ,0 )) AS MTOPRESUP]
   cCom:="SUM(IF("+GetWhereAnd("ASP_FECHA",dDesde,dHasta)+[ AND ASP_MONTO="CO", ASP_MONTO   ,0 )) AS MTOCOMPRO]
   cEje:="SUM(IF("+GetWhereAnd("ASP_FECHA",dDesde,dHasta)+[ AND ASP_MONTO="CA", ASP_MONTO   ,0 )) AS MTOEJECUT]
   cPag:="SUM(IF("+GetWhereAnd("ASP_FECHA",dDesde,dHasta)+[ AND ASP_MONTO="PA", ASP_MONTO   ,0 )) AS MTOPAGADO]

   // Lectura Presupuesto
   cSql:="SELECT ASP_CODCTA,"+;
         cPre+","+;
         cCom+","+;
         cEje+","+;
         cPag+;
         " FROM DPASIENTOSPRE WHERE "+cWhereG+" "+;
         " GROUP BY ASP_CODCTA "+;
         " ORDER BY ASP_CODCTA "

   IF oDp:lPrecontab
     cSql:=STRTRAN(cSql,"DPASIENTOSPRE","DPASIENTOSPREPREC")
   ENDIF 

   oTable:=OpenTable(cSql,.T.)

   // ? CLPCOPY(oDp:cSql)
   // 15/03/2022 Remover saldo Anterior
 
   DPWRITE("TEMP\BPCALCULAR.SQL",cSql)
   DPWRITE("TEMP\BRWBALANCEPRESUPUESTARIO.SQL",cSql)

   oTable:Gotop()
   oTable:Replace("MTOPAGADO",0)

   WHILE !oTable:Eof()
     //  oTable:Replace("MTOPAGADO",oTable:ANTERIOR+oTable:MTOCOMPR-oTable:MTOEJEC)
     nMtoPre:=nMtoPre+oTable:MTOPRESUP
     nMtoCom:=nMtoCom+oTable:MTOCOMPRO
     nMtoEje:=nMtoEje+oTable:MTOEJECUT
     oTable:DbSkip()
   ENDDO

   oTable:GoBottom()
   cCodCta:=oTable:ASP_CODCTA

   oCuentas:=OpenTable(" SELECT CPP_CODIGO,CPP_DESCRI,CPP_TIPO FROM DPCTAPRESUP WHERE CPP_CODIGO"+GetWhere("<=",cCodCta)+;
                       " ORDER BY CPP_CODIGO",.T.)

   WHILE !oCuentas:Eof()
      oCuentas:REPLACE("CPP_CODIGO",ALLTRIM(oCuentas:CPP_CODIGO))
      oCuentas:DbSkip()
   ENDDO

   oCuentas:Replace("COL"      , 0        ) // Columna
   oCuentas:Replace("MTOPRESUP", 0        )
   oCuentas:Replace("MTOCOMPRO", 0        )
   oCuentas:Replace("MTOEJECUT", 0        )
   oCuentas:Replace("MTOPAGADO", 0        )
   oCuentas:Replace("TIPO"     , "C"      ) // Cuentas
   oCuentas:Replace("NUM"      , 0        ) // Cuentas
   oCuentas:Replace("TITULO"   , SPACE(40))
   oCuentas:Replace("ASIENTO"  , 1        ) // Acepta Asientos
   oCuentas:Replace("NIVEL"    , 0        ) // Acepta Asientos

   _PRESUP :=oCuentas:FieldPos("MTOPRESUP")
   _COMPRO :=oCuentas:FieldPos("MTOCOMPRO")
   _EJECUT :=oCuentas:FieldPos("MTOEJECUT")
   _PAGADO :=oCuentas:FieldPos("MTOPAGADO")
   _TIPO   :=oCuentas:FieldPos("TIPO"     )
   _NUM    :=oCuentas:FieldPos("NUM"      )
   _TITULO :=oCuentas:FieldPos("TITULO"   )
   _ASIENTO:=oCuentas:FieldPos("ASIENTO"  )
   _NIVEL  :=oCuentas:FieldPos("NIVEL"    )
   _COL    :=oCuentas:FieldPos("COL"      )

   // Calcula los Saldos
   oTable:GoTop()

   WHILE !oTable:Eof() 

      cCodCta:=ALLTRIM(oTable:ASP_CODCTA)

      // oTable:REPLACE("ASP_ASIENTO",.T.)
      WHILE LEN(cCodCta)>0

         nAt:=ASCAN(oCuentas:aDataFill,{|a,n|a[1]==cCodCta})

         IF nAt>0
        
            oCuentas:Goto(nAt)
            oCuentas:REPLACE("MTOPRESUP", oCuentas:MTOPRESUP+ oTable:MTOPRESUP   )
            oCuentas:REPLACE("MTOCOMPRO", oCuentas:MTOCOMPRO+ oTable:MTOCOMPRO   )
            oCuentas:REPLACE("MTOEJECUT", oCuentas:MTOEJECUT+ oTable:MTOEJECUT   )
            oCuentas:REPLACE("MTOPAGADO", oCuentas:MTOPAGADO+ oTable:MTOPAGADO   )
            oCuentas:REPLACE("ASIENTO"  , IF(cCodCta==ALLTRIM(oTable:ASP_CODCTA) , 1 , 0 ))

         ENDIF

         cCodCta:=LEFT(cCodCta,LEN(cCodCta)-1)

      ENDDO

      oTable:DbSkip()

   ENDDO
 
 
   // Depura Cuentas sin Montos
   WHILE LEN(oCuentas:aDataFill)>0

     nAt:=ASCAN(oCuentas:aDataFill,{|a,n| a[_PRESUP]=0 .AND. a[_COMPRO]=0 .AND. a[_EJECUT]=0 .AND. a[_PAGADO]=0 })

     IF nAt=0
        EXIT
     ENDIF

     oCuentas:aDataFill:=ARREDUCE(oCuentas:aDataFill,nAt)

   ENDDO

   IF LEN(oCuentas:aDataFill)>0
     aData   :=ACLONE(ATAIL(oCuentas:aDataFill))
     AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})

     aData[1]       :="TOTAL"
     aData[_PRESUP] :=nMtoPre
     aData[_COMPRO] :=nMtoCom
     aData[_EJECUT] :=nMtoEje
     aData[_PAGADO] :=nMtoPre+nMtoCom-nMtoEje

     AADD(oCuentas:aDataFill,aData)
     aCuentas:=ACLONE(oCuentas:aDataFill)
     aSaldos :=ACLONE(aCuentas)

     HacerBal()

     oCuentas:aDataFill:=ACLONE(aNew)

   ENDIF

   WHILE LEN(oCuentas:aDataFill)>0

     nAt:=ASCAN(oCuentas:aDataFill,{|a,n|a[_NUM]=0})

     IF nAt=0
        EXIT
     ENDIF

     oCuentas:aDataFill:=ARREDUCE(oCuentas:aDataFill,nAt)

   ENDDO

   nColMax:=nNivMax

//   oCuentas:Browse()

  FOR I=1 TO LEN(oCuentas:aFields)
      IF oCuentas:aFields[I,2]<>ValType(oCuentas:FieldGet(2))
         oCuentas:aFields[I,2]:=ValType(oCuentas:FieldGet(2))
         oCuentas:aFields[I,3]:=20+IIF(oCuentas:aFields[I,2]="C",2,0)
         oCuentas:aFields[I,4]:=0 
      ENDIF
   NEXT I

  
   IF ValType(oGenRep)="O" .AND. (oGenRep:oRun:nOut=6 .OR. oGenRep:oRun:nOut=7 .OR. oGenRep:oRun:nOut=8)

      oDatos:=OpenTable("SELECT CPP_DESCRI AS PERIODO FROM DPCTAPRESUP",.F.)
      oDatos:AddRecord(.T.)
      oDatos:Replace("PERIODO" ,DTOC(RGO_C1)+" AL "+DTOC(RGO_C2) )
      oDatos:Replace("SUCURSAL",SQLGET("DPSUCURSAL","SUC_DESCRI","SUC_CODIGO"+GetWhere("=",RGO_C7)))
      oDatos:CTODBF(oDp:cPathCrp+Alltrim(oGenRep:REP_CODIGO)+"ENC.DBF")
      oDatos:End() 

      oCuentas:CTODBF(oDp:cPathCrp+Alltrim(oGenRep:REP_CODIGO)+".DBF")
      oGenRep:oRun:lFileDbf:=.T. // ya Existe

      IF "BAL"$oGenRep:REP_CODIGO

        USE (oDp:cPathCrp+Alltrim(oGenRep:REP_CODIGO)+".DBF") EXCLU
        GO TOP 
      
        DELETE FOR COL="6".AND.TIPO="R" 
        PACK 
        CLOSE ALL 
 
      ENDIF



   ENDIF

   // 31/03/2022
   aData:={}
   oCuentas:GoTop()

   WHILE !oCuentas:EOF()

     IF oCuentas:TIPO="R" 
       AADD(aData,{oCuentas:CPP_CODIGO,oCuentas:TITULO    ,oCuentas:MTOPRESUP,oCuentas:MTOCOMPRO,oCuentas:MTOEJECUT,oCuentas:MTOPAGADO,oCuentas:TIPO,oCuentas:COL})
     ELSE
       AADD(aData,{oCuentas:CPP_CODIGO,oCuentas:CPP_DESCRI,oCuentas:MTOPRESUP,oCuentas:MTOCOMPRO,oCuentas:MTOEJECUT,oCuentas:MTOPAGADO,oCuentas:TIPO,oCuentas:COL})
     ENDIF

     oCuentas:DbSkip()

  ENDDO

  oDp:aBalComIni:=ACLONE(aData)

// ViewArray(oDp:aBalComIni)

RETURN oCuentas

FUNCTION HacerBal()
   LOCAL cCod1,cCod2,cCod3,cCod4,cCod5,cCod6,cCod7,cCod8,cCod9
   LOCAL nPos1,nPos2,nPos3,nPos4,nPos5,nPos6,nPos7,nPos8,nPos9
   LOCAL nCan1,nCan2,nCan3,nCan4,nCan5,nCan6,nCan7,nCan8,nCan9
   LOCAL nNiv1,nNiv2,nNiv3,nNiv4,nNiv5,nNiv6,nNiv7,nNiv8,nNiv9
   LOCAL nLen1,nLen2,nLen3,nLen4,nLen5,nLen6,nLen7,nLen8,nLen9
   LOCAL nNivCta:=0
   // DR20071123
   LOCAL lTot1,lTot2,lTot3,lTot4,lTot5,lTot6,lTot7

   aNew:={}
   oCuentas:GoTop()

   nLen1:= LEN(oCuentas:CPP_CODIGO)

   // Todas las Cuentas ppales deben poseer 1, Digito pata Todos
  
   DpMsgClose()
   DpMsgRun("Procesando","Creando Presupuesto",NIL,oCuentas:RecCount(),NIL,.T.)
   DpMsgSetTotal(oCuentas:RecCount(),"Procesando","cText")

   WHILE !oCuentas:Eof()

      nNivCta:=0


      DpMsgSet(oCuentas:RecNo(),.T.,oCuentas:CPP_CODIGO)

      cCod1 :=oCuentas:CPP_CODIGO
      nPos1 :=oCuentas:Recno()
      nNivel:=1
      // DR20071123
      lTot1:=LTOTAL(cCod1,LEN(cCod1))

      IF LEN(oCuentas:CPP_CODIGO)<>nLen1 .OR. nNivel>nMaxCol
         oCuentas:DbSkip()
         LOOP
      ENDIF

      SETCUENTA()
      // Busca todas las Hijas de 1,2,3

      WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CPP_CODIGO,nLen1)=cCod1

         // ? "AQUI DEBE BUSCAR 1.1.",LEFT(oCuentas:CPP_CODIGO,nLen1),cCod1,oCuentas:CPP_CODIGO

         IF LEN(oCuentas:CPP_CODIGO)<=nLen1 .OR. nNivel>nMaxCol
            oCuentas:DbSkip()
            LOOP
         ENDIF

         nPos2 :=oCuentas:Recno()
         cCod2 :=oCuentas:CPP_CODIGO
         nLen2 :=LEN(cCod2)
         nNivel:=2
         // DR20071123
         lTot2:=LTOTAL(cCod2,LEN(cCod2))

         SETCUENTA()

         WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CPP_CODIGO,nLen2)=cCod2

            IF LEN(oCuentas:CPP_CODIGO)<=nLen2 .OR. nNivel>nMaxCol
               oCuentas:DbSkip()
               LOOP
            ENDIF

            cCod3 :=oCuentas:CPP_CODIGO
            nLen3 :=LEN(cCod3)
            nPos3 :=oCuentas:Recno()
            nNivel:=3
            // DR20071123
            lTot3:=LTOTAL(cCod3,LEN(cCod3))


            SETCUENTA()

            WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CPP_CODIGO,nLen3)=cCod3

               IF LEN(oCuentas:CPP_CODIGO)<=nLen3 .OR. nNivel>nMaxCol
                  oCuentas:DbSkip()
                  LOOP
               ENDIF
  
               cCod4 :=oCuentas:CPP_CODIGO
               nLen4 :=LEN(cCod4)
               nPos4 :=oCuentas:Recno()
               nNivel:=4
               // DR20071123
               lTot4:=LTOTAL(cCod4,LEN(cCod4))
   
               SETCUENTA()

               WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CPP_CODIGO,nLen4)=cCod4  

                  IF LEN(oCuentas:CPP_CODIGO)<=nLen4 .OR. nNivel>nMaxCol
                     oCuentas:DbSkip()
                     LOOP
                  ENDIF

                  cCod5 :=oCuentas:CPP_CODIGO
                  nLen5 :=LEN(cCod5)
                  nPos5 :=oCuentas:Recno()
                  nNivel:=5
                  // DR20071123
                  lTot5:=LTOTAL(cCod5,LEN(cCod5))
   
                  SETCUENTA()

                  WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CPP_CODIGO,nLen5)=cCod5  

                    IF LEN(oCuentas:CPP_CODIGO)<=nLen5 .OR. nNivel>nMaxCol
                       oCuentas:DbSkip()
                       LOOP
                    ENDIF

                    cCod6 :=oCuentas:CPP_CODIGO
                    nLen6 :=LEN(cCod6)
                    nPos6 :=oCuentas:Recno()
                    nNivel:=6
                    // DR20071123
                    lTot6:=LTOTAL(cCod6,LEN(cCod6))
   
                    SETCUENTA()

                    WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CPP_CODIGO,nLen6)=cCod6  

                      IF LEN(oCuentas:CPP_CODIGO)<=nLen6 .OR. nNivel>nMaxCol
                         oCuentas:DbSkip()
                         LOOP
                      ENDIF
  
                      cCod7 :=oCuentas:CPP_CODIGO
                      nLen7 :=LEN(cCod7)
                      nPos7 :=oCuentas:Recno()
                      nNivel:=7
                      // DR20071123
                      lTot7:=LTOTAL(cCod7,LEN(cCod7))

                      SETCUENTA()

                      WHILE !oCuentas:Eof() .AND. LEFT(oCuentas:CPP_CODIGO,nLen7)=cCod7  

                        IF LEN(oCuentas:CPP_CODIGO)<=nLen7 .OR. nNivel>nMaxCol
                          oCuentas:DbSkip()
                          LOOP
                        ENDIF
  
                        cCod8 :=oCuentas:CPP_CODIGO
                        nLen8 :=LEN(cCod8)
                        nPos8 :=oCuentas:Recno()
                        nNivel:=8

                        SETCUENTA()

                        oCuentas:DbSkip()

                      ENDDO

                      IF lTot7
                         TOTALCUENTA(7,nPos7)
                       ENDIF

                   ENDDO

                   IF lTot6
                      TOTALCUENTA(6,nPos6)
                   ENDIF
              
                 ENDDO

                 IF lTot5
                    TOTALCUENTA(5,nPos5)
                  ENDIF

               ENDDO

               IF lTot4
                  TOTALCUENTA(4,nPos4)
               ENDIF

            ENDDO

            IF lTot3
               TOTALCUENTA(3,nPos3) // Antes nPos2
            ENDIF

         ENDDO

         IF lTot2
            TOTALCUENTA(2,nPos2)
         ENDIF

      ENDDO

      IF lTot1
         TOTALCUENTA(1,nPos1)
      ENDIF

   ENDDO

   oCuentas:GoBottom()
   TOTALCUENTA(1 , oCuentas:Recno() )
   oCuentas:aDataFill:=ACLONE(aNew)

   DpMsgClose()

 
RETURN oCuentas

/*
// Califica la Cuenta
*/
FUNCTION SETCUENTA(nPos)
    LOCAL aData,lAsiento:=.F.,lOk:=.F.,cTotal:=""

    nPos:=oCuentas:Recno()

    IF oCuentas:ASIENTO=1
       lAsiento:=.T.
    ENDIF

    oCuentas:REPLACE("TITULO"  ,ALLTRIM(oCuentas:CPP_CODIGO)+SPACE(nNivel)+oCuentas:CPP_DESCRI)
    oCuentas:Replace("COL",nNivel)

    IF nNivel=nMaxCol .OR. EJECUTAR("ISCTADETPRESUP",oCuentas:CPP_CODIGO,.F.)

       // Este es el Nivel Maximo
       lOk:=.T.

       IF lTotales 

         // 31/03/2022 Atail(aNew)[_NEW]:=LEN(aNew)
         aData:=ACLONE(oCuentas:aDataFill[nPos])
         AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
         AADD(aNew,ACLONE(aData))

       ENDIF

       oCuentas:Replace("TIPO","D") // Cuenta de Detalle
       oCuentas:REPLACE("MTOPRESUP",BUILDTOTAL(TRAN(oCuentas:MTOPRESUP,cPicture)))
       oCuentas:REPLACE("MTOCOMPRO",BUILDTOTAL(TRAN(oCuentas:MTOCOMPRO,cPicture)))
       oCuentas:REPLACE("MTOEJECUT",BUILDTOTAL(TRAN(oCuentas:MTOEJECUT,cPicture)))
       oCuentas:REPLACE("MTOPAGADO",BUILDTOTAL(TRAN(oCuentas:MTOPAGADO,cPicture)))

       AADD(aNew,ACLONE(oCuentas:aDataFill[nPos]))

    ELSE

       oCuentas:REPLACE("MTOPRESUP","")
       oCuentas:REPLACE("MTOCOMPRO","")
       oCuentas:REPLACE("MTOEJECUT","")
       oCuentas:REPLACE("MTOPAGADO","")

    ENDIF

    IF nNivel<nMaxCol // Cuenta Titulo

       lOk:=.T.

       IF lTotales

         // 31/03/2022 Atail(aNew)[_NEW]:=LEN(aNew)
         aData:=ACLONE(oCuentas:aDataFill[nPos])
         AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
         AADD(aNew,ACLONE(aData))

       ENDIF

       oCuentas:Replace("TIPO ","T") // Titulo
       oCuentas:Replace("COL",nNivel)

       AADD(aNew,ACLONE(oCuentas:aDataFill[nPos]))

    ENDIF

    lTotales:=.F.

    Atail(aNew)[_NUM]:=LEN(aNew)

RETURN .T.

FUNCTION TOTALCUENTA(nNiv,nPos)
  LOCAL nRec:=oCuentas:Recno(),aData:={},nAt,cCol

  nNivel:=nNiv

  nNivMax:=MAX(nNivMax,nNiv)

  IF nNivel<nMaxCol-1 //  Romer Simacas


    // Agrega las Rayas
    aData:=ACLONE(oCuentas:aDataFill[nPos])

    IF nNivel!=1 

        AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})

        aData[_PRESUP]:=REPLICATE("-",40)
        aData[_COMPRO]:=REPLICATE("-",40)
        aData[_EJECUT]:=REPLICATE("-",40)
        aData[_PAGADO]:=REPLICATE("-",40)

        AADD(aNew,ACLONE(aData))
        Atail(aNew)[_NUM]:=LEN(aNew)

     ELSE

        // Separador
        AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})

        aData[_PRESUP]:=REPLICATE("=",40)
        aData[_COMPRO]:=REPLICATE("=",40)
        aData[_EJECUT]:=REPLICATE("=",40)
        aData[_PAGADO]:=REPLICATE("=",40)

        AADD(aNew,ACLONE(aData))
        Atail(aNew)[_NUM]:=LEN(aNew)

     ENDIF

     aData:=ACLONE(oCuentas:aDataFill[nPos])

     aData[_TITULO  ]:=ALLTRIM(cTextT)+" "+aData[2]
     aData[_TIPO    ]:="R"
     aData[_NIVEL   ]:=nNivel

     nAt:=ASCAN(aSaldos,{|a,n|a[1]==aData[1]})

     IF nAt>0
       aData[_PRESUP]:=BUILDTOTAL(TRAN(aSaldos[ nAt,_PRESUP],cPicture))
       aData[_COMPRO]:=BUILDTOTAL(TRAN(aSaldos[ nAt,_COMPRO    ],cPicture))
       aData[_EJECUT]:=BUILDTOTAL(TRAN(aSaldos[ nAt,_EJECUT   ],cPicture))
       aData[_PAGADO]:=BUILDTOTAL(TRAN(aSaldos[ nAt,_PAGADO   ],cPicture))
     ENDIF

     AADD(aNew , ACLONE(aData) )
     Atail(aNew)[_NUM]:=LEN(aNew)

     IF nNivel=1 

        // Separador
        AEVAL(aData,{|a,n|aData[n]:=CTOEMPTY(a)})
        AADD(aNew,ACLONE(aData))
        Atail(aNew)[_NUM   ]:=LEN(aNew)
        Atail(aNew)[_PRESUP]:=""
        Atail(aNew)[_COMPRO]:=""
        Atail(aNew)[_EJECUT]:=""
        Atail(aNew)[_PAGADO]:=""
     ENDIF

     lTotales:=.T.

  ENDIF

  // Atail(aNew)[6]:=LEN(aNew)
  Atail(aNew)[_NUM]:=LEN(aNew)

RETURN .T.

FUNCTION BUILDTOTAL(cTotal)

   IF oDp:cBalCre="-" .OR. !("-"$cTotal)
      RETURN cTotal
   ENDIF

   IF oDp:cBalCre="C" .AND. "-"$cTotal
      cTotal:=STRTRAN(cTotal,"-","")+"CR"
   ENDIF

   IF oDp:cBalCre="(" .AND. "-"$cTotal
      cTotal:="("+ALLTRIM(STRTRAN(cTotal,"-",""))+")"
   ENDIF

RETURN cTotal

// DR20071123
FUNCTION LTOTAL(cCodCta,nLenAct)
 LOCAL lTotal
 LOCAL cWhere:="LEFT(CPP_CODIGO,"+ALLTRIM(STR(nLenAct))+")"+GetWhere("=",cCodCta)+" AND LENGTH(CPP_CODIGO)"+GetWhere(">",nLenAct)

 lTotal:=COUNT("DPCTAPRESUP",cWhere)>0

RETURN lTotal
// EOF
