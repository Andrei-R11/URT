cd "C:\Users\a.romero11\OneDrive\CEDE\URT\Bases de datos\06-25-2019\"
use "Encuesta Hogares URT_corregida", clear
label define categorias 1 "Sí" 0 "No"
label define SiNo 1"Sí" 0"No"
scalar PPA =1344.144
scalar lineaPobrezaExtrema= 74.427294
scalar lineaPobreza=125.86821
/*******************************************************Ingreso Y Pobreza************************************************************************/
{
use "Encuesta Hogares URT_corregida", clear
*Ingreso de renta de activos
		egen ingRent=rowtotal(d1_c d1_d)
		replace ingRent=(ingRent/personas_hogar)/PPA
		label var ingRent "Ingreso mensual per cápita normal por renta de activos; alquileres, intereses utilidades $moneda"
		sum ingRent, det		
*Ingreso por ayuda de familiar
		egen ingAyuFam=rowtotal(d1_e d1_f)
		replace ingAyuFam=(ingAyuFam/personas_hogar)/PPA
		label var ingAyuFam "Ingreso mensual per cápita normal por ayuda familiar; nacional o del extranjero $moneda"
		sum ingAyuFam, det
		replace ingAyuFam=. if ingAyuFam>r(p99) & ingAyuFam!=.
		replace ingAyuFam=. if  ingAyuFam==0
*Ingreso por Pensión, prestaciones o demanda por alimentos
		egen ingPenDivo= rowtotal(d1_g d1_h)
		replace ingPenDivo= (ingPenDivo/personas_hogar)/PPA
		label var ingPenDivo "Ingreso mensual per cápita normal por pensiones, o divorcio" 
		sum ingPenDivo, det
		replace ingPenDivo=. if ingPenDivo>r(p99) & ingPenDivo!=.
*Ingreso agrícola y no agrícola
	edit numero_hogar d1_a if d1_a <0
	replace d1_a = 960000 in 661
		gen ingAgro=d1_b
		gen ingNoAgro=d1_a
		replace ingNoAgro=(ingNoAgro/personas_hogar)/PPA
		replace ingAgro=(ingAgro/personas_hogar)/PPA
		label var ingNoAgro "Ingreso mensual per cápita normal por actividades no agropecuarias $moneda"
		label var ingAgro "Ingreso mensual per cápita normal por actividades agropecuarias $moneda"
		sum ingAgro, det
		replace ingAgro=. if ingAgro>r(p99) & ingAgro!=.
		
		sum ingNoAgro, det
		replace ingNoAgro=. if ingNoAgro>r(p99) & ingNoAgro!=.
*Ingreso por programas MFA y Protección al adulto mayor
		egen ingMFApam=rowtotal(d1_i d1_j)
		replace ingMFApam=(ingMFApam/personas_hogar)/PPA
		label var ingMFApam "Ingreso mensual per cápita normal por Más Familias en Acción y Programa protecció al adulto mayor"
		sum ingMFApam, det
		replace ingMFApam=.  if ingMFApam>r(p99) & ingMFApam!=.
*Otros ingresos
		gen ingOtros=d1_k
		replace ingOtros=(ingOtros/personas_hogar)/PPA
		label var ingOtros "Ingreso mensual per cápita normal por otros ingresos"
		sum ingOtros, det
		replace ingOtros=. if ingOtros>r(p99) & ingOtros!=.
*Ingreso total
		egen ingTotal= rowtotal(ing*)
		label var ingTotal "Ingreso mensual per cápita por hogar"
		sum ingTotal, det
		replace ingTotal=. if ingTotal>r(p99) & ingTotal!=.
**Tipos de hogar según ingresos**
		gen pobreza=.
		replace pobreza=1 if ingTotal<=lineaPobreza & ingTotal>lineaPobrezaExtrema & ingTotal!=.
		replace pobreza=2 if ingTotal<=lineaPobrezaExtrema & ingTotal!=.
		replace pobreza=3 if ingTotal>lineaPobreza & ingTotal!=.
**Dummy pobreza**
		gen dummy_pobreza=1 if ingTotal<=lineaPobreza & ingTotal!=.
		replace dummy_pobreza=0 if ingTotal>lineaPobreza & ingTotal!=.
}
/********************************************************Gastos***********************************************************************************/
{
use "Encuesta Hogares URT_corregida", clear
*Gasto por diversión y entretenimiento
	egen gastDiver=rowtotal(d2_?_b)
	replace gastDiver=(gastDiver/personas_hogar)/PPA
	replace gastDiver=gastDiver*4
	label var gastDiver "Gasto mensual per cápita por diversión y entretenimiento"
*Gasto por transporte
	egen gastTrans=rowtotal(d3_?_b)
	replace gastTrans=(gastTrans/personas_hogar)/PPA
	replace gastTrans=gastTrans*4
	label var gastTrans "Gasto mensual semana per cápita por transporte"
*Gasto por educación miembros del hogar
	egen gastEdu=rowtotal(d3_?_b)
	replace gastEdu=(gastEdu/personas_hogar)/PPA
	label var gastEdu "Gasto en el último mes per cápita por educación"
*Otros gastos
	egen gastOtros=rowtotal(cuanto_deudas cuanto_arriendo cuanto_aseo cuanto_recarga)
	replace gastOtros=(gastOtros/personas_hogar)/PPA
	label var gastOtros "Gasto en el último mes per cápita por otros gastos o inversiones"
*Gasto por servicios
	egen gastServi=rowtotal(cuanto_energia cuanto_gas cuanto_acueducto cuanto_alcantarillado cuanto_basuras ///
		cuanto_television cuanto_fijo cuanto_internet_hogar cuanto_combo cuanto_acueducto_alcantarillado)	
	replace gastServi=(gastServi/personas_hogar)/PPA
	label var gastServi "Gasto en el útlimo mes per cápita por servicios del hogar"
*Gasto por salud
	egen gastSalud=rowtotal(cuanto_medicamentos cuanto_consulta cuanto_urgencias cuanto_terapia cuanto_seguro_medico cuanto_otros_salud)
	replace gastSalud=(gastSalud/personas_hogar)/PPA
	label var gastSalud "Gasto en el útlimo mes per cápita por salud"
*Otros gastos anuales
	egen gastAnua=rowtotal(cuanto_vestuario cuanto_electrodomesticos cuanto_articulos_vivienda cuanto_compra_celular ///
		cuanto_compra_casa cuanto_compra_vehiculo cuanto_otros_compras)
	replace gastAnua= (gastAnua/personas_hogar)/PPA
	replace gastAnua=gastAnua/12
	label var gastAnua "Gasto mensual per cápita por otros gastos o inversiones"	
*Gasto por alimentos
	egen gastAlimen=rowtotal(gasto_total_pescado cuanto_gasto*)
	replace gastAlimen=(gastAlimen/personas_hogar)/PPA
	replace gastAlimen=gastAlimen*4
	label var gastAlimen "Gasto mensual per cápita por alimentos"
*Gasto alimentos regalados o producidos
preserve
	drop valor_regalo_patron_*
	egen gastAlimenProducidos=rowtotal(estima_regalo_pescado valor_regalo_*)
	replace gastAlimenProducidos=(gastAlimenProducidos/personas_hogar)/PPA
	replace gastAlimenProducidos=gastAlimenProducidos*4
	label var gastAlimenProducidos "Gasto mensual per cápita por alimentos regalados o producidos"
	sum gastAlimenProducidos, det
	hist gastAlimenProducidos
	keep numero_hogar gastAlimenProducidos
	save "Gasto_alimentos_recibidos.dta", replace
restore
*Gasto Total
	egen gastTotal=rowtotal(gastDiver gastTrans gastEdu gastOtros gastServi gastAnua gastAlimen)
	label var gastTotal "Gasto mensual per cápita"
	sum gastTotal, det
	replace gastTotal =. if gastTotal >r(p99) & gastTotal !=.
}
/********************************************************Finanzas*********************************************************************************/
{
use "Encuesta Hogares URT_corregida", clear
*Ahorro formal
	*Presencia
		rename i1_ahorro_entidad_financierra ahorPreFormal
		label var ahorPreFormal "Presencia de ahorro formal"
		label values ahorPreFormal categorias
	*Cuantía
		gen ahorroFormal=i2_/PPA
		label var ahorroFormal "Valor del ahorro formal total (PPA)"
	sum ahorroFormal , det
	replace ahorroFormal=. if ahorroFormal >=r(p99)
*Ahorro informal
	*Presencia
		gen ahorPreInformal=0
		replace ahorPreInformal=1 if si_no_efectivo==1 | si_no_alcancias==1 | si_no_efectivo_extranjera==1 | ///
		ahorPreInformal==1 | si_no_prestamos_otras_personas==1 | si_no_amigos_parientes | ///
		si_no_patron_jefe==1 | si_no_materiales_construccion==1 | si_no_ahorro_otro==1 | si_no_joyas==1 | si_no_animales_domesticos==1 | ///
		si_no_vivienda_lote==1 |  si_no_guarda_otro==1
		label var ahorPreInformal "Presencia de ahorro informal"
		label values ahorPreInformal categorias
	*Cuantía
		egen ahorroInformal=rowtotal(cuanto_efectivo cuanto_alcancias efectivo_extranjero cuanto_cadenas_fondos ///
			prestamos_otras_personas cuanto_amigos_parientes cuanto_patron_jefe cuanto_ahorro_otro cuanto_joyas ///
			animales_domesticos cuanto_vivienda_lote materiales_construccion cuanto_guarda_otro)
		replace ahorroInformal= ahorroInformal/PPA
		label var ahorroInformal "Valor del ahorro informal total (PPA)"
		sum ahorroInformal , det
		replace ahorroInformal =. if ahorroInformal >r(p99)
*Crédito formal
	*Presencia
		rename i8_credito_entidad_financiera credPreFormal
		label var credPreFormal "Presencia del crédito formal"
		label values credPreFormal categorias
	*Cuantía
		gen creditoFormal=i9_/PPA
		label var creditoFormal "Valor del crédito formal total (PPA)"
	sum creditoFormal, det
	replace creditoFormal=. if creditoFormal>=r(p99)
*Crédito informal
	*Presencia
		gen credPreInformal=0
		replace credPreInformal=1 if si_no_familiares_amigos==1 | si_no_empresa==1 | si_no_jefe==1 | si_no_tienda==1 | ///
		si_no_gota_gota==1 | si_no_casa_empeno==1 | si_no_prestamista==1 | si_no_almacen==1 | ///
		si_no_servicios_publicos==1 | si_no_fondo_empleados==1
		label var credPreInformal "Presencia de crédito informal"
		label values credPreInformal categorias
	*Cuantía
		egen creditoInformal=rowtotal(cuanto_familiares_amigos cuanto_empresa cuanto_jefe cuanto_tienda cuanto_gota_gota ///
		cuanto_casa_empeno cuanto_prestamista cuanto_almacen cuanto_servicios_publicos cuanto_fondo_empleados)
		replace creditoInformal=creditoInformal/PPA
		label var creditoInformal "Valor del crédito informal total (PPA)"
	sum creditoInformal, det
	replace creditoInformal=0 if creditoInformal>r(p99)
*Créditos como complemento de PPP
	gen creditoComplementoPPP= i12/PPA
	label var creditoComplementoPPP "Valor del crédito complementario al apoyo del PPP (PPA)"
}
/********************************************************Activos**********************************************************************************/
{
use "Encuesta Hogares URT_corregida", clear
*Especies menores
	egen actValorEspMenor=rowtotal(valor_cabras valor_cerdos valor_colmenas valor_conejos valor_cuyes ///
		valor_gallinas valor_otras_aves valor_ovejas valor_peces)
	replace actValorEspMenor=actValorEspMenor/PPA
	label var actValorEspMenor "Valor total de las especies menores del hogar (USDppa)"
	
	egen actPreEspMenor=rowmax( si_no_ovejas si_no_cerdos si_no_cabras si_no_gallinas si_no_otras_aves ///
		si_no_conejos si_no_colmenas si_no_peces si_no_cuyes)
	label var actPreEspMenor "¿El hogar reporta tenencia de especies menores? (1=Sí)"
	label val actPreEspMenor SiNo
*Especies mayores
	egen actValorEspMayor=rowtotal(valor_toros valor_vacas valor_novillos valor_terneros ///
		valor_burros valor_mulas valor_caballos)
	replace actValorEspMayor=actValorEspMayor/PPA
	label var actValorEspMayor "Valor total de las especies mayores del hogar (USDppa)"
	
	egen actPreEspMayor=rowmax(si_no_toros si_no_vacas si_no_novillos  ///
		 si_no_terneros si_no_burros si_no_mulas si_no_caballos)
	label var actPreEspMayor "¿El hogar reporta tenencia de especies mayores? (1=Sí)"
	label val actPreEspMayor SiNo
*Implementos agrícolas básicos
	egen actValorBasicos=rowtotal(valor_machete valor_hacha valor_azadon valor_palas valor_carretilla ///
		valor_guadana valor_sembra_manual valor_bomba_mochila valor_arado valor_descerezadora valor_desgranadora)
	replace actValorBasicos=actValorBasicos/PPA
	label var actValorBasicos "Valor total de los implementos agrícolas básicos (USDppa)"
	
	egen actCuantosBasicos=rowmean(cuanto_machete cuanto_hacha cuanto_azadon cuanto_palas ///
		cuanto_carretilla cuanto_guadana cuanto_sembra_manual cuanto_bomba_mochila ///
		cuanto_arado cuanto_descerezadora cuanto_desgranadora)
	label var actCuantosBasicos "Número de implementos agrícolas básicos promedio por hogar"
	
	egen actPreBasicos=rowmax(si_no_machete si_no_hacha si_no_azadon si_no_palas si_no_carretilla ///
		si_no_guadana si_no_sembra_manual si_no_bomba_mochila si_no_arado si_no_descerezadora si_no_desgranadora)
	label var actPreBasicos "¿El hogar reporta tenencia de implementos agrícolas básicos? (1=Sí)"
	label val actPreBasicos SiNo
*Implementos agrícolas especializados
	egen actValorEspeciali =rowtotal(f5_?_c)
	replace actValorEspeciali= actValorEspeciali/PPA
	label var actValorEspeciali "Valor total de los implementos agrícolas especializados (USDppa)"
	
	egen actPreEspeciali=rowmax(f5_?_a)
	label var actPreEspeciali "¿El hogar reporta tenencia de implementos agrícolas especializados? (1=Sí)"
	label val actPreEspeciali SiNo
*Instalaciones agrícolas
	egen actValorInfra=rowtotal(costo_*)
	replace actValorInfra=actValorInfra/PPA
	label var actValorInfra "Valor total de las instalaciones agrícolas (USDppa)"
	
	egen actPreInfra=rowmax(si_no_secadora_solar si_no_establos si_no_estanque_peces si_no_corrales ///
		si_no_bebedero si_no_sistema_riego si_no_cercas si_no_galpones si_no_otros_instalaciones_agrico)
	label var actPreInfra "¿El hogar reporta tenencia de instalaciones agrícolas? (1=Sí)"
	label val actPreInfra SiNo
*Bienes duraderos del hogar
	egen actValorHogar=rowtotal(valor_radio_activos valor_televisor valor_licuadora valor_equipo_sonido ///
		valor_estufa_electrica valor_estufa_4_hornillas valor_nevera valor_ducha_electrica ///
		valor_vehiculos valor_motocicleta valor_bicicleta_adulto valor_lavadora valor_celular ///
		valor_maquina_coser valor_otros_activos)
	replace actValorHogar=actValorHogar/PPA
	label var actValorHogar "Valor total de los bienes duraderos del hogar (USDppa)"
	
	egen actPreHogar=rowmax(poseen*)
	label var actPreHogar "¿El hogar reporta tenencia de bienes duraderos? (1=Sí)"
	label val actPreHogar SiNo
}
/********************************************************Fuerza de trabajo************************************************************************/
{
use "Capítulo_BLONG", clear
label define SiNo 1"Sí" 0"No"
scalar PPA =1344.144
**Ocupación principal**
	gen minutos_horas= minutos_ocupacion_ultimos_/60
	egen horasPrin= rowtotal(horas_ocupacion_ultimos_dias_  minutos_horas) if b2_==1
	replace horasPrin=horasPrin/7
	label var horasPrin "Horas de trabajo efectivo diario ocupación principal"
**Ocupación secundaria**
	gen minutos_horas_efectivo= minutos_trabajo_efectivo_/60
	egen horasSecu= rowtotal(horas_trabajo_efectivo_  minutos_horas_efectivo) if b17_==1
	replace horasSecu=horasSecu/7
	label var horasSecu "Horas de trabajo efectivo diario ocupación secundaria"
**Horas totales**
	egen horasTotales=rowtotal(horasPrin horasSecu) if horasPrin!=. | horasSecu!=.
	label var horasTotales "Horas de trabajo efectivo diario"
	collapse horasPrin horasSecu horasTotales, by(numero_hogar)
	merge 1:1 numero_hogar using "Encuesta Hogares URT_corregida"
**Ingreso laboral**
	use "capítulo_ALONG", clear
	merge 1:1 numero_hogar individuo using "capítulo_BLONG"
	
}
/********************************************************Composición y Educación******************************************************************/
{
use "Capítulo_ALONG", clear
label define SiNo 1"Sí" 0"No"
label define nivel 0"Ninguno" 1"Preescolar" 2"Primaria" 3"Secundaria" 4"Técnico o tecnológico" 5"Universidad"
*Nivel de educación*
	egen nivelEdu=rowmax(a9_ a12_)
	label values nivelEdu nivel
*Años de escolaridad*
	gen tecAl= (grado_alcanzado_tecnico/2)+11 if grado_alcanzado_tecnico>0 
	gen tecAct= (grado_actual_tecnico/2)+11 if grado_actual_tecnico>0
	gen unAl= (grado_alcanzado_universidad/2)+11 if grado_alcanzado_universidad>0
	gen unAct= (grado_actual_universidad/2)+11 if grado_actual_universidad>0
	
	egen anosEduAl= rowtotal(grado_alcanzado_preescolar_ grado_alcanzado_primaria_ ///
		grado_alcanzado_secundaria_ tecAl unAl) if a9_ !=.
	egen anosEduAc=rowtotal(grado_actual_preescolar_ grado_actual_primaria_ ///
		grado_actual_secundaria_ tecAct unAct) if a12_!=.
	egen anosEdu=rowmax(anosEduAl anosEduAc) if a9_ !=. | a12_ !=.
*Número de hombres en el hogar*
	egen personasHombre=count(a3_) if a3_==1, by(numero_hogar)
	label var personasHombres "Número de hombres en el hogar"
*Número de mujeres en el hogar
	egen personasMujer=count(a3_) if a3_==0, by(numero_hogar)
	label var personasMujer "Número de mujeres en el hogar"
*Número de menores (18 años) en el hogar
	egen personasMenores=count(persomas_hogar) if a2_<=18, by(numero_hogar)
	label var personasMenores "Número de menores (18 años) en el hogar"
*Edad promedio del hogar
	egen personasPromEdad=total(a2_/personas_hogar), by(numero_hogar)

}
/********************************************************Tierras**********************************************************************************/
{
use "Encuesta Hogares URT_corregida", clear
gen presen_huerta=c45_presencia_huerta
label values presen_huerta categorias
**Primera y segunda línea productiva**
replace principal_linea_produc="" if principal_linea_produc=="99"
replace secun_linea_produc="" if secun_linea_produc=="99"
replace secun_linea_produc="" if secun_linea_produc=="0"

	gen primera_linea_produccion=.
replace primera_linea_produccion =1 if principal_linea_produc=="Abono para café"
replace primera_linea_produccion =2 if principal_linea_produc=="Aguacate"
replace primera_linea_produccion =2 if principal_linea_produc=="Banano"
replace primera_linea_produccion =1 if principal_linea_produc=="CAFÉ"
replace primera_linea_produccion =2 if principal_linea_produc=="Cacao"
replace primera_linea_produccion =1 if principal_linea_produc=="Cafe"
replace primera_linea_produccion =3 if principal_linea_produc=="Cafe y platano"
replace primera_linea_produccion =3 if principal_linea_produc=="Cafe-platano"
replace primera_linea_produccion =1 if principal_linea_produc=="Café"
replace primera_linea_produccion =4 if principal_linea_produc=="Café y limón taiti"
replace primera_linea_produccion =3 if principal_linea_produc=="Café y platano"
replace primera_linea_produccion =5 if principal_linea_produc=="Caña"
replace primera_linea_produccion =5 if principal_linea_produc=="Caña panelera"
replace primera_linea_produccion =6 if principal_linea_produc=="Cerdos"
replace primera_linea_produccion =6 if principal_linea_produc=="Cerdos de engorde"
replace primera_linea_produccion =7 if principal_linea_produc=="Cría de cuyes"
replace primera_linea_produccion =8 if principal_linea_produc=="Cría de ganado"
replace primera_linea_produccion =9 if principal_linea_produc=="Cuajada"
replace primera_linea_produccion =1 if principal_linea_produc=="Cultivo café"
replace primera_linea_produccion =3 if principal_linea_produc=="Cultivo café y platano"
replace primera_linea_produccion =2 if principal_linea_produc=="Cultivo de Aguacate"
replace primera_linea_produccion =10 if principal_linea_produc=="Cultivo de CACAO aguacate y platano"
replace primera_linea_produccion =1 if principal_linea_produc=="Cultivo de Cafe"
replace primera_linea_produccion =1 if principal_linea_produc=="Cultivo de café"
replace primera_linea_produccion =4 if principal_linea_produc=="Cultivo de café y limón"
replace primera_linea_produccion =3 if principal_linea_produc=="Cultivo de café y platano"
replace primera_linea_produccion =10 if principal_linea_produc=="Cultivo de chocolate platano y cafe"
replace primera_linea_produccion =7 if principal_linea_produc=="Cuyes"
replace primera_linea_produccion =8 if principal_linea_produc=="Doble propósito"
replace primera_linea_produccion =6 if principal_linea_produc=="Engorde de cerdos"
replace primera_linea_produccion =1 if principal_linea_produc=="Fertilizantes para sostener café"
replace primera_linea_produccion =11 if principal_linea_produc=="Gallinas"
replace primera_linea_produccion =11 if principal_linea_produc=="Gallinas Ponedoras"
replace primera_linea_produccion =11 if principal_linea_produc=="Gallinas doble propósito"
replace primera_linea_produccion =11 if principal_linea_produc=="Gallinas pollos y huerta"
replace primera_linea_produccion =11 if principal_linea_produc=="Gallinas ponedoras"
replace primera_linea_produccion =11 if principal_linea_produc=="Galpón para gallinas ponedoras"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganaderia"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganaderia doble propósito"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganadería"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganadería de levante"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganadería doble propósito"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganado"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganado de Ceba"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganado de carne"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganado de ceba"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganado de ceba de engorde"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganado de cria"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganado de engorde"
replace primera_linea_produccion =9 if principal_linea_produc=="Ganado de leche"
replace primera_linea_produccion =9 if principal_linea_produc=="Ganado de ordeño"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganado doble propósito"
replace primera_linea_produccion =9 if principal_linea_produc=="Ganado leche"
replace primera_linea_produccion =9 if principal_linea_produc=="Ganado para leche"
replace primera_linea_produccion =8 if principal_linea_produc=="Ganado vacuno"
replace primera_linea_produccion =2 if principal_linea_produc=="Granadilla"
replace primera_linea_produccion =12 if principal_linea_produc=="Huerta"
replace primera_linea_produccion =1 if principal_linea_produc=="Insumos Para café y platano y para ce.."
replace primera_linea_produccion =9 if principal_linea_produc=="Leche"
replace primera_linea_produccion =9 if principal_linea_produc=="Lecheria"
replace primera_linea_produccion =2 if principal_linea_produc=="Lulo"
replace primera_linea_produccion =1 if principal_linea_produc=="Mantenimiento de Café"
replace primera_linea_produccion =1 if principal_linea_produc=="Mantenimiento de café"
replace primera_linea_produccion =1 if principal_linea_produc=="Mantenimiento de cultivo de café"
replace primera_linea_produccion =1 if principal_linea_produc=="Mantenimiento del cultivo de café"
replace primera_linea_produccion =1 if principal_linea_produc=="Mantenimiento para el café"
replace primera_linea_produccion =2 if principal_linea_produc=="Maracuya"
replace primera_linea_produccion =6 if principal_linea_produc=="Marranos"
replace primera_linea_produccion =8 if principal_linea_produc=="Mejorar terrenos para Ganado"
replace primera_linea_produccion =2 if principal_linea_produc=="Mora"
replace primera_linea_produccion =11 if principal_linea_produc=="Pavos"
replace primera_linea_produccion =5 if principal_linea_produc=="Pañela  caña"
replace primera_linea_produccion =15 if principal_linea_produc=="Peces"
replace primera_linea_produccion =15 if principal_linea_produc=="Piscicultura"
replace primera_linea_produccion =13 if principal_linea_produc=="Platano"
replace primera_linea_produccion =10 if principal_linea_produc=="Platano y cacao"
replace primera_linea_produccion =13 if principal_linea_produc=="Plátano"
replace primera_linea_produccion =14 if principal_linea_produc=="Pollos"
replace primera_linea_produccion =14 if principal_linea_produc=="Pollos de engorde"
replace primera_linea_produccion =14 if principal_linea_produc=="Pollos de levante"
replace primera_linea_produccion =8 if principal_linea_produc=="Producción de ganado vacuno"
replace primera_linea_produccion =2 if principal_linea_produc=="Siembra de banano"
replace primera_linea_produccion =8 if principal_linea_produc=="Terneros para engorde"
replace primera_linea_produccion =2 if principal_linea_produc=="Tomate"
replace primera_linea_produccion =2 if principal_linea_produc=="Tomate de Mesa bajo invernadero"
replace primera_linea_produccion =15 if principal_linea_produc=="Trucha"
replace primera_linea_produccion =8 if principal_linea_produc=="VACAS"
replace primera_linea_produccion =8 if principal_linea_produc=="Vacas"

	gen segunda_linea_produccion=.
replace segunda_linea_produccion =14 if secun_linea_produc=="15 pollos de engorde y 15 gallinas Po.."
replace segunda_linea_produccion =2 if secun_linea_produc=="Aguacate"
replace segunda_linea_produccion =1 if secun_linea_produc=="Beneficiafero de café"
replace segunda_linea_produccion =16 if secun_linea_produc=="CERDO de cría y gallinas"
replace segunda_linea_produccion =2 if secun_linea_produc=="Cacao"
replace segunda_linea_produccion =1 if secun_linea_produc=="Cafe"
replace segunda_linea_produccion =1 if secun_linea_produc=="Café"
replace segunda_linea_produccion =3 if secun_linea_produc=="Café y platano"
replace segunda_linea_produccion =3 if secun_linea_produc=="Café y plátano y pollos de engorde"
replace segunda_linea_produccion =8 if secun_linea_produc=="Carne"
replace segunda_linea_produccion =5 if secun_linea_produc=="Caña"
replace segunda_linea_produccion =6 if secun_linea_produc=="Cerdos"
replace segunda_linea_produccion =16 if secun_linea_produc=="Cerdos de cría  y pollos de engorde"
replace segunda_linea_produccion =6 if secun_linea_produc=="Cerdos de engorde"
replace segunda_linea_produccion =8 if secun_linea_produc=="Comprar GANADO y Mula"
replace segunda_linea_produccion =7 if secun_linea_produc=="Cria de cuyes"
replace segunda_linea_produccion =7 if secun_linea_produc=="Cría de cuy"
replace segunda_linea_produccion =15 if secun_linea_produc=="Cría de peces"
replace segunda_linea_produccion =3 if secun_linea_produc=="Cultivo de café, platano"
replace segunda_linea_produccion =10 if secun_linea_produc=="Cultivo de chocolate platano y cafe"
replace segunda_linea_produccion =7 if secun_linea_produc=="Cuyes"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas Ponedoras"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas criollas"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas criollas y huerta"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas de engorde"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas de postura"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas doble propósito"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas ponedoraa"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas ponedoras"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas y pollos"
replace segunda_linea_produccion =11 if secun_linea_produc=="Gallinas y pollos de engorde"
replace segunda_linea_produccion =7 if secun_linea_produc=="Galpon de cuyes"
replace segunda_linea_produccion =7 if secun_linea_produc=="Galpón"
replace segunda_linea_produccion =8 if secun_linea_produc=="Ganado"
replace segunda_linea_produccion =8 if secun_linea_produc=="Ganado doble proposir5"
replace segunda_linea_produccion =8 if secun_linea_produc=="Ganado doble propósito"
replace segunda_linea_produccion =9 if secun_linea_produc=="Ganado tipo leche"
replace segunda_linea_produccion =8 if secun_linea_produc=="Ganado vacuno"
replace segunda_linea_produccion =12 if secun_linea_produc=="Huerta"
replace segunda_linea_produccion =12 if secun_linea_produc=="Huerta  casera"
replace segunda_linea_produccion =12 if secun_linea_produc=="Huerta casera"
replace segunda_linea_produccion =12 if secun_linea_produc=="Huerta casera más POLLAS ponedoras"
replace segunda_linea_produccion =12 if secun_linea_produc=="Huerta casera y gallinas"
replace segunda_linea_produccion =12 if secun_linea_produc=="Huerta de casera"
replace segunda_linea_produccion =12 if secun_linea_produc=="Huerta familiar"
replace segunda_linea_produccion =11 if secun_linea_produc=="Huevos"
replace segunda_linea_produccion =9 if secun_linea_produc=="Leche"
replace segunda_linea_produccion =2 if secun_linea_produc=="Limón"
replace segunda_linea_produccion =2 if secun_linea_produc=="Limón Tahití"
replace segunda_linea_produccion =2 if secun_linea_produc=="Limón tahti"
replace segunda_linea_produccion =2 if secun_linea_produc=="Limón taiti"
replace segunda_linea_produccion =5 if secun_linea_produc=="Maiz"
replace segunda_linea_produccion =1 if secun_linea_produc=="Mantenimiento de café"
replace segunda_linea_produccion =1 if secun_linea_produc=="Mantenimiento de café ya sembrado"
replace segunda_linea_produccion =6 if secun_linea_produc=="Marranos"
replace segunda_linea_produccion =6 if secun_linea_produc=="Marranos para seguridad alimentaria"
replace segunda_linea_produccion =5 if secun_linea_produc=="Maíz"
replace segunda_linea_produccion =17 if secun_linea_produc=="Mejoramiento de pasto"
replace segunda_linea_produccion =2 if secun_linea_produc=="Mora"
replace segunda_linea_produccion =8 if secun_linea_produc=="Mula"
replace segunda_linea_produccion =18 if secun_linea_produc=="NA"
replace segunda_linea_produccion =18 if secun_linea_produc=="Ninguno"
replace segunda_linea_produccion =18 if secun_linea_produc=="No"
replace segunda_linea_produccion =18 if secun_linea_produc=="No hay"
replace segunda_linea_produccion =18 if secun_linea_produc=="No le han dado"
replace segunda_linea_produccion =18 if secun_linea_produc=="No le han linea"
replace segunda_linea_produccion =18 if secun_linea_produc=="No tiene"
replace segunda_linea_produccion =18 if secun_linea_produc=="No tuvo"
replace segunda_linea_produccion =18 if secun_linea_produc=="No tuvo sino un proyecto."
replace segunda_linea_produccion =8 if secun_linea_produc=="Ovejas de pelo"
replace segunda_linea_produccion =14 if secun_linea_produc=="POLLOS de engorde"
replace segunda_linea_produccion =17 if secun_linea_produc=="Pasto"
replace segunda_linea_produccion =17 if secun_linea_produc=="Pasto de Corte"
replace segunda_linea_produccion =17 if secun_linea_produc=="Pasto de corte"
replace segunda_linea_produccion =17 if secun_linea_produc=="Pasto de corte y pasto brechara"
replace segunda_linea_produccion =15 if secun_linea_produc=="Peces"
replace segunda_linea_produccion =15 if secun_linea_produc=="Pescado"
replace segunda_linea_produccion =15 if secun_linea_produc=="Pescados"
replace segunda_linea_produccion =13 if secun_linea_produc=="Platano"
replace segunda_linea_produccion =13 if secun_linea_produc=="Platano y yuca"
replace segunda_linea_produccion =13 if secun_linea_produc=="Plátano"
replace segunda_linea_produccion =13 if secun_linea_produc=="Plátano y banano"
replace segunda_linea_produccion =13 if secun_linea_produc=="Plátano,yuca maiz"
replace segunda_linea_produccion =14 if secun_linea_produc=="Pollos"
replace segunda_linea_produccion =14 if secun_linea_produc=="Pollos de engorde"
replace segunda_linea_produccion =14 if secun_linea_produc=="Pollos de engorde y Ponedoras"
replace segunda_linea_produccion =14 if secun_linea_produc=="Pollos y gallinas"
replace segunda_linea_produccion =14 if secun_linea_produc=="Pollos y huerta"
replace segunda_linea_produccion =6 if secun_linea_produc=="Porcicultura"
replace segunda_linea_produccion =12 if secun_linea_produc=="Productos de la huerta casera"
replace segunda_linea_produccion =9 if secun_linea_produc=="Queso"
replace segunda_linea_produccion =17 if secun_linea_produc=="Recuperación de cultivos"
replace segunda_linea_produccion =18 if secun_linea_produc=="Seguridad alimentaria"
replace segunda_linea_produccion =14 if secun_linea_produc=="Seguridad alimentaria pollos"
replace segunda_linea_produccion =1 if secun_linea_produc=="Sostenimiento de café"
replace segunda_linea_produccion =8 if secun_linea_produc=="Terneras engorde"
replace segunda_linea_produccion =8 if secun_linea_produc=="Terneros de engorde"
replace segunda_linea_produccion =2 if secun_linea_produc=="Tomate"
replace segunda_linea_produccion =5 if secun_linea_produc=="Veneficiadero para hacer panela"
replace segunda_linea_produccion =17 if secun_linea_produc=="pasto de corte"

label define clase_primera 1"Café" 2"Frutales" 3"Café y platano" 4"Café y limón" 5"Caña" 6"Cerdos" 7"Cuyes" 8"Ganadería" ///
	9"Lacteos y leche" 10"Cacao, aguacate y plátano" 11"Gallinas" 12"Huerta" 13"Plátano" 14"Pollos" 15"Peces"
label define clase_segunda 1"Café" 2"Frutales" 3"Café y platano" 4"Café y limón" 5"Caña" 6"Cerdos" 7"Cuyes" 8"Ganadería" ///
	9"Lacteos y leche" 10"Cacao, aguacate y platano" 11"Gallinas" 12"Huerta" 13"Platano" 14"Pollos" 15"Peces" 16"Cerdos y gallinas" ///
	17"Pastos" 18"Ninguna"
	
label values primera_linea_produccion clase_primera
label values segunda_linea_produccion clase_segunda

}
/********************************************************IPM**************************************************************************************/
{
*A. Condiciones educativas del hogar
*1 Privacion por bajo logro educativo
use "capítulo_ALONG", clear
	gen tecAl= (grado_alcanzado_tecnico/2)+11 if grado_alcanzado_tecnico>0 
	gen unAl= (grado_alcanzado_universidad/2)+11 if grado_alcanzado_universidad>0

	gen numeroAñosEstudio = .
	replace numeroAñosEstudio= grado_alcanzado_preescolar_ if a9_==1 & a2_ > 15 & a2_ !=.
	replace numeroAñosEstudio= grado_alcanzado_primaria_ if a9_==2 & a2_ >15 & a2_ !=.
	replace numeroAñosEstudio= grado_alcanzado_secundaria_ if a9_==3 & a2_ >15 & a2_ !=.
	replace numeroAñosEstudio= tecAl if a9_==4 & a2_ >15 & a2_ !=.
	replace numeroAñosEstudio= unAl if a9_==5 & a2_ >15 & a2_ !=.
	replace numeroAñosEstudio=0 if a9_==0  & a2_>15 & a2_!=.


	gen edad15Men=1 if a2_<=15 & a2_!=.
	egen personas15Men= total(edad15Men), by(numero_hogar)
	gen prop15Men = personas15Men/personas_hogar

	collapse numeroAñosEstudio prop15Men (sum) personas15Men ,by (numero_hogar)
	gen privacion1 = .
	replace privacion1 = 1 if numeroAñosEstudio < 9 & numeroAñosEstudio !=.
	replace privacion1 = 1 if prop15Men == 1
	replace privacion1 = 0 if numeroAñosEstudio >= 9 & numeroAñosEstudio !=.
	save "privacion1", replace
*2 Analfabetismo
use "capítulo_ALONG", clear
	egen analfabetismo=count(a7_) if a7_==0 & a2_>15 & a2_!=. , by(numero_hogar)
	egen alfabetismo=count(a7_) if a7_==1 & a2_>15 & a2_!=. , by(numero_hogar)
	
	gen edad15Men=1 if a2_<=15 & a2_!=.
	egen personas15Men= total(edad15Men), by(numero_hogar)
	gen prop15Men = personas15Men/personas_hogar
	
	collapse (max) analfabetismo alfabetismo (mean) prop15Men, by(numero_hogar)
	gen privacion2= .
	replace privacion2 = 1 if analfabetismo != .
	replace privacion2 = 0 if alfabetismo == .
	replace privacion2 = 1 if prop15Men == 1
	save "privacion2", replace
*B. Condiciones de la ninnez y la juventud
*3. Privacion por rezago escolar
use "capítulo_ALONG", clear
	gen tecAl= (grado_alcanzado_tecnico/2)+11 if grado_alcanzado_tecnico>0 
	gen unAl= (grado_alcanzado_universidad/2)+11 if grado_alcanzado_universidad>0
	
	gen añosEstudio2=.
	replace añosEstudio2=0 if a9_==0 & (a2_ >=7 & a2_<=17) & a2_!=.
	replace añosEstudio2=grado_alcanzado_preescolar_ if a9_==1 & (a2_ >=7 & a2_<=17) & a2_!=. 
	replace añosEstudio2= grado_alcanzado_primaria_ if a9_==2 & (a2_ >=7 & a2_<=17) & a2_!=. 
	replace añosEstudio2= grado_alcanzado_secundaria_ if a9_==3 & (a2_ >=7 & a2_<=17) & a2_!=. 
	replace añosEstudio2= tecAl if a9_==4 & (a2_ >=7 & a2_<=17) & a2_!=. 
	replace añosEstudio2= unAl if a9_==5 & (a2_ >=7 & a2_<=17) & a2_!=. 

	gen privacion3h=.
	replace privacion3h=1 if (añosEstudio2 < 1 & añosEstudio2!=.) & a2_==7
	replace privacion3h=0 if (añosEstudio2 >= 1 & añosEstudio2!=.) & a2_==7
	replace privacion3h=1 if (añosEstudio2 < 2 & añosEstudio2!=.) & a2_ ==8
	replace privacion3h=0 if (añosEstudio2 >= 2 & añosEstudio2!=.) & a2_==8
	replace privacion3h=1 if (añosEstudio2 < 3 & añosEstudio2!=.) & a2_==9
	replace privacion3h=0 if (añosEstudio2 >= 3 & añosEstudio2!=.) & a2_==9
	replace privacion3h=1 if (añosEstudio2 < 4 &  añosEstudio2!=. ) &  a2_==10
	replace privacion3h=0 if (añosEstudio2 >= 4 & añosEstudio2!=. ) &  a2_==10
	replace privacion3h=1 if (añosEstudio2 < 5 &  añosEstudio2!=. ) &  a2_==11
	replace privacion3h=0 if (añosEstudio2 >= 5 &  añosEstudio2!=. ) &  a2_==11
	replace privacion3h=1 if (añosEstudio2 < 6 &  añosEstudio2!=. ) &  a2_==12
	replace privacion3h=0 if (añosEstudio2 >= 6 &  añosEstudio2!=. ) &  a2_==12
	replace privacion3h=1 if (añosEstudio2 < 7 &  añosEstudio2!=. ) &  a2_==13
	replace privacion3h=0 if (añosEstudio2 >= 7 &  añosEstudio2!=. ) &  a2_==13
	replace privacion3h=1 if (añosEstudio2 < 8 &  añosEstudio2!=. ) &  a2_==14
	replace privacion3h=0 if (añosEstudio2 >= 8 &  añosEstudio2!=. ) &  a2_==14
	replace privacion3h=1 if (añosEstudio2 < 9 &  añosEstudio2!=. ) &  a2_==15
	replace privacion3h=0 if (añosEstudio2 >= 9 &  añosEstudio2!=. ) &  a2_==15
	replace privacion3h=1 if (añosEstudio2 < 10 &  añosEstudio2!=. ) &  a2_==16
	replace privacion3h=0 if (añosEstudio2 >= 10 &  añosEstudio2!=. ) &  a2_==16
	replace privacion3h=1 if (añosEstudio2 < 11 & añosEstudio2!=.) & a2_==17
	replace privacion3h=0 if (añosEstudio2 >=11 & añosEstudio2!=.) & a2_==17


	egen privacion3= sum(privacion3h), by(numero_hogar)
	collapse privacion3, by (numero_hogar)
	replace privacion3 = 1 if privacion3 > 0 & privacion3 !=.
	replace privacion3 = 0 if privacion3 == 0 & privacion3 !=.
	save "privacion3", replace
*4. Privacion por inasistencia escolar
use "capítulo_ALONG", clear
	gen inasistenciaEscolar= 1 if (a11_ ==0 & a11_ !=.) & (a2_>=6 & a2_<=16 & a2_!=.)
	replace inasistenciaEscolar= 0 if a11_ & (a2_>=6 & a2_<=16 & a2_!=.)

	egen privacion4= sum(inasistenciaEscolar), by(numero_hogar)
	collapse privacion4, by(numero_hogar)
	replace privacion4=1 if privacion4 > 0 & privacion4 !=.
	replace privacion4 = 0 if privacion4 == 0 & privacion4 !=.
	save "privacion4", replace
*5. Privacion por acceso a servicios de cuidado a la primera infancia
use "Encuesta Hogares URT_corregida", clear
**a**
	rename e23_ privacion5a
	keep privacion5a numero_hogar
	save "privacion5a", replace
**b**
use "capítulo_ALONG", clear
	gen privacion5b=.
	replace privacion5b=1 if a16_==3 | a16_==5
	replace privacion5b=0 if a16_==1 | a16_==2 | a16_==7
	egen numeroEdad5Men= count(a2_edad) if a2_edad<5 & a2_edad!=.
	
	collapse privacion5b numeroEdad5Men, by(numero_hogar)
	replace privacion5b=1 if privacion5b>0 & privacion5b!=.
	replace privacion5b=0 if privacion5b==0 & privacion5b!=.
	replace privacion5b=0 if numeroEdad5Men==.
	
	save "privacion5b", replace
	merge 1:1 numero_hogar using "privacion5a"
	gen privacion5=1 if privacion5a==1 | privacion5b==1
	replace privacion5=0 if privacion5 !=1 & (privacion5a==0 | privacion5b==0)
	save "privacion5", replace
*6. Privacion por trabajo infantil
use "capítulo_ALONG", clear
merge 1:1 numero_hogar individuo using "capítulo_BLONG"
	gen privacion6=1 if (b2_==1 | b17_==1) & (a2_edad>=12 & a2_edad<=17) & a2_edad!=.
	replace privacion6=0 if ((b2_ >1 & b2_!=.) & ///
		(b17_==2 | b17_==3 | b17_==.)) & (a2_edad>=12 & a2_edad<=17) & a2_edad!=.
	egen numeroEdad12Men= count(a2_) if a2_edad>=12 & a2_edad<= 17 & a2_edad!=.
	
	collapse privacion6 numeroEdad12Men, by(numero_hogar)
	replace privacion6 = 1 if privacion6 > 0 & privacion6 != .
	replace privacion6 = 0 if privacion6 == 0 & privacion6 != .
	replace privacion6 = 0 if numeroEdad12Men == .
	save "privacion6", replace
*7. Privacion por falta de aseguramiento en salud
use "Encuesta Hogares URT_corregida", clear
	rename e22_t privacion7
	label define SiNo 1"Sí" 0"No"
	label values privacion7 SíNo
	keep privacion7 numero_hogar                   
	save "privacion7", replace
*8. Privacion por barreras de acceso a salud dada una necesidad
use "Encuesta Hogares URT_corregida", clear
	gen privacion8 = .
	replace privacion8 = 1 if (e24_ == 1) & (e25_ == 5 | e25_ == 6 | e25_ == 7 | e25_ == 8 | e25_==9)
	replace privacion8 = 0 if (e24_ == 0) 
	replace privacion8 = 0 if (e24_ == 1) & (e25_ == 1 | e25_ == 2 | e25_ == 3 | e25_ == 4)
	keep privacion8 numero_hogar
	save "privacion8", replace
*D. TRABAJO
*9. Privacion por desempleo de larga duracion
*Poblacion economicamente activa PEA
use "capítulo_BLONG", clear
	gen edad=real(recuperar_edad_)
	recode edad (99=.)
	keep if edad>=12 & edad!=.
	gen ocupados = .
	replace ocupados = 0 if b2_ > 1 & b2_ !=.
	replace ocupados = 1 if b2_ == 1 | b17_ == 1
	 
	gen desocupados = .
	replace desocupados = 1 if b15_ == 1
	replace desocupados = 0 if b17_ == 1 | b2_ != 2

	gen PEA = .
	replace PEA = 1 if ocupados == 1 | desocupados == 1
	replace PEA = 0 if ocupados ==0 & desocupados == 0 

	gen privacion9 = .
	replace privacion9 = 1 if PEA == 1 & b16_ == 1
	replace privacion9 = 0 if PEA == 0 | (PEA == 1 & ocupado == 1)| (PEA==1 & b16_ == 0)
	egen noPEA = sum (PEA), by(numero_hogar)
	replace privacion9 = 1 if noPEA == 0 

	collapse privacion9, by (numero_hogar)
	replace privacion9 = 1 if privacion9 >0 & privacion9 !=.
	save "privacion9", replace
*10. Privacion por empleo formal
use "Capítulo_ALONG", clear
	merge 1:1 numero_hogar individuo using "Capítulo_BLONG", nogen
	gen edad=real(recuperar_edad_)
	recode edad (99=.)
	keep if edad>=12 & edad!=.
	gen ocupados = .
	replace ocupados = 0 if b2_ > 1 & b2_ !=.
	replace ocupados = 1 if b2_ == 1 | b17_ == 1
	 
	gen desocupados = .
	replace desocupados = 1 if b15_ == 1
	replace desocupados = 0 if b17_ == 1 | b2_ != 2

	gen PEA = .
	replace PEA = 1 if ocupados == 1 | desocupados == 1
	replace PEA = 0 if ocupados ==0 & desocupados == 0 
	replace PEA = . if ocupados ==  1 & edad < 18 & a3 !=.
	replace PEA = . if b16_buscar_trabajo_ == 1
	
	gen formal = 1 if PEA == 1 & ocupados == 1 & b29_aporta_fondo_pensiones_ == 1
	replace formal = 1 if a15_pension_si_no_ == 1 & PEA == 1 
	replace formal = 0 if PEA == 1 & ocupados == 1 & b29_aporta_fondo_pensiones_ == 0
	replace formal = 0 if a15_pension_si_no_ == 0 & PEA == 1

	egen PEA_hogar = sum (PEA), by(numero_hogar)
	collapse formal PEA_hogar, by (numero_hogar)
	gen privacion10 = . 
	replace privacion10 = 1 if formal == 0 
	replace privacion10 = 0 if formal > 0 & formal != . 
	replace privacion10 = 1 if PEA_hogar == 0
	save "privacion10", replace
*11. Privacion por acceso de agua mejorada 
use "Encuesta Hogares URT_corregida", clear	
	gen privacion11=1 if e10_a!=1 & e10_a!=2
	replace privacion11=0 if e10_a==1
	replace privacion11=0 if e10_a==2
*12. Privacion por inadecuada eliminacion de excretas
	gen privacion12=1 if e17_==0
	replace privacion12=1 if e17_==1 & e18_!=1 & e18_!=2
	replace privacion12=0 if e17_==1 & (e18_==1 | e18_==2)
*13. Privacion por material inadecuado de los pisos
	gen privacion13=1 if e6_==7
	replace privacion13=0 if e6_!=7
*14. Privacion por material inadecuado de las paredes exteriores (Pentiente)
	gen privacion14= 1 if e5_== 4 | e5_== 5 | e5_== 6 | e5_== 7 | e5_== 8 | e5_== 9
	replace privacion14=0 if e5_==1 | e5_==2 | e5_==3
	keep privacion11  privacion12  privacion13 privacion14 numero_hogar
	save "privacion11a14", replace
*15. Hacinamiento critico
use "Encuesta Hogares URT_corregida", clear	
	gen hacinamiento = personas_hogar/cuartos_dormir
	gen privacion15 = 1 if  hacinamiento >= 3 & hacinamiento !=.
	replace privacion15 = 0 if  hacinamiento < 3 & hacinamiento !=.
	keep privacion15 numero_hogar
	save "privacion15", replace
****Uniendo las bases****
use privacion1, clear
merge 1:1 numero_hogar using privacion2, nogen
merge 1:1 numero_hogar using privacion3, nogen
merge 1:1 numero_hogar using privacion4, nogen
merge 1:1 numero_hogar using privacion5, nogen
merge 1:1 numero_hogar using privacion6, nogen
merge 1:1 numero_hogar using privacion7, nogen
merge 1:1 numero_hogar using privacion8, nogen
merge 1:1 numero_hogar using privacion9, nogen
merge 1:1 numero_hogar using privacion10, nogen
merge 1:1 numero_hogar using privacion11a14, nogen
merge 1:1 numero_hogar using privacion15, nogen

save IPM, replace
***Labels***
use IPM, clear
label var privacion1 "1 Privacion por bajo logro educativo"
label var privacion2 "2 Analfabetismo"
label var privacion3   "3. Privacion por rezago escolar"
label var privacion4   "4. Privacion por inasistencia escolar"
label var privacion5 "5. Privacion por acceso a servicios de cuidado a la primera infancia salud < 5"
label var privacion6 "6. Privacion por trabajo infantil"
label var privacion7 "7. Privacion por falta de aseguramiento en salud"
label var privacion8 "8. Privacion por barreras de acceso a salud dada una necesidad"
label var privacion9 "9. Privacion por desempleo de larga duracion"
label var privacion10 "10. Privacion por empleo formal"
label var privacion11 "11. Privacion por acceso de agua mejorada"
label var privacion12 "12. Privacion por inadecuada eliminacion de excretas"
label var privacion13 "13. Privacion por material inadecuado de los pisos"
label var privacion14 "14. Privacion por material inadecuado de las paredes exteriores"
label var privacion15 "15. Hacinamiento critico"

****Puntaje****
forvalues num=1/15{
	replace privacion`num'=0 if privacion`num'==.
}
gen educacion = privacion1*0.5 + privacion2*0.5
gen niñezJuventud = privacion3*0.25 + privacion4 * 0.25 + privacion5*0.25 + privacion6*0.25
gen trabajo = privacion9*0.5+ privacion10*0.5
gen salud = privacion7*0.5 + privacion8*0.5
gen vivienda = privacion11*0.2 + privacion12*0.2+ privacion13*0.2+ privacion14*0.2+ privacion15*0.2

*****IPM General*****
gen IPMgeneral = educacion*0.2+ niñezJuventud*0.2+ salud*0.2+ trabajo*0.2+ vivienda*0.2 
save IPM2, replace
use "Encuesta Hogares URT_corregida", clear
merge 1:1 numero_hogar using IPM2, nogen
 

}
/********************************************************Seguridad alimentaria********************************************************************/
{
use "Encuesta Hogares URT_corregida", clear
label values j1_alimentos_preocupacion-j20_menor_5_anos_desayunar_almor categorias
	
egen escInsegAli=rowtotal(j1_-j9_ j11_-j17_), m 
label var escInsegAli "Número de respuestas negativas en Seguridad Alimentaria"

rename j10_ menEdad

gen punELCSA=escInsegAli
recode punELCSA (1/3=1) (4/6=2) (7/9=3) if menEdad==0			
recode punELCSA (1/5=1) (6/10=2) (11/16=3) if menEdad!=0	
label define punELCSA 0 "Seg Alimentaria" 1 "Inseg Leve" 2 "Inseg Moderada" /*
					   */3 "Inseg Severa"	
label val punELCSA punELCSA
label var punELCSA "Puntaje ELCSA de Inseguridad Alimentaria"

}
/********************************************************Locus de control*************************************************************************/
{
use "Encuesta Hogares URT_corregida", clear

*Internality
	gen locInter=(lider+accidente_buen_conductor+planes_funcionar+cantidad_amigos+determinar_vida ///
		+proteger_intereses+obtiene_trabajar+propias_acciones)/8
	replace locInter= (locInter -1)/(5-1)
	replace locInter= locInter*100
	label var locInter "Puntaje de Locus - Interno (1 a 100)"

*Powerful
	gen locPow=(personas_poderosas+posiciones_liderazgo+totalmente_personas_poderosas+deseos_acorde_poderosas)/4
	replace locPow= (locPow -1)/(5-1)
	replace locPow= locPow*100
	label var locPow "Puntaje de Locus - Externo y por entes de más poder (1 a 100)"

*Chance
	gen locChance=(buena_mala_suerte+eventos_desafortunados+conseguir_suerte+pasar_pasara+accidente_suerte ///
		+planes_buena_mala_suerte+lider_suerte+destino_amigos)/8
	replace locChance= (locChance -1)/(5-1)
	replace locChance= locChance*100
	label var locChance "Puntaje de Locus - Externo y por suerte (1 a 100)"

}
/********************************************************Otros programas y Capital social*********************************************************/
{
use "Encuesta Hogares URT_corregida", clear
*Participación otros programas
	egen participoProgramas=rowmax(g1_?_a g1_??_a)
	label val participoProgramas SiNo
*Capital Social
	*Estructural*
		egen ssc1=rowmean(k1_?_a k1_10_a)
		label var ssc1 "Densidad organizacional"
		
		recode k5 (1=0) (2 3 4 =3) (5=2), gen(ssc2)
		replace ssc2=ssc2/3
		label var ssc2 "redes y apoyo mutuo"
		
		recode k3 (1=0) (2=1) (3 4 5 6 9 =2) (7 8 =3), gen(ssc3)
		replace ssc3=ssc3/3
		label var ssc3 "Expectativas sobre redes y apoyo"
		
		recode k2 (1=0) (2=1) (3=2) (4=3), gen(ssc4)
		replace ssc4=ssc4/3
		label var ssc4 "Acción colectiva"
		
		egen SSC= rowmean(ssc1 ssc2 ssc3 ssc4)
		label var SSC "Capital Social Estructural"
	*Cognitivo*
		recode k4 (1=1) (2 3=2) (4 5 6 7 8 =3) (9 10 11 12 14=4) (13=0), gen(csc1)
		replace csc1=csc1/4
		label var csc1 "Solidaridad"

		recode k6 (1=1) (0=2), gen (csc2)
		replace csc2=csc2/2
		label var csc2 "Cooperación"
		
		egen CSC= rowmean(csc1 csc2)
		label var CSC "Capital Social Cognitivo"


}
/********************************************************Aspiraciones y Expectativas**************************************************************/
{
use "Encuesta Hogares URT_corregida", clear
*Escaleras de bienestar
	rename (l2_escalon_bienestar l3_desea_cinco_anos l4_cree_cinco_anos l5_desearia_dos_anos l6_cree_dos_anos) ///
			(escBnstar aspBnstar5 expBnstar5 aspBnstar2 expBnstar2)
	recode escBnstar aspBnstar5 expBnstar5 aspBnstar2 expBnstar2 (99=.)
*Brechas
	gen lagAsp5= aspBnstar5-escBnstar
	label var lagAsp5 "Diferencia entre el escalón aspirado a 5 años con el actual"
	replace lagAsp5=0 if lagAsp5<0
	gen lagExp5= expBnstar5-escBnstar
	label var lagExp5 "Diferencia entre el escalón esperado a 5 años con el actual"
	replace lagExp5=0 if lagExp5<0
	gen lagAsp2= aspBnstar2-escBnstar
	label var lagAsp2 "Diferencia entre el escalón aspirado a 2 años con el actual"
	replace lagAsp2=0 if lagAsp2<0
	gen lagExp2= expBnstar2-escBnstar
	label var lagExp2 "Diferencia entre el escalón esperado a 2 años con el actual"
	replace lagExp2=0 if lagExp2<0

}
/********************************************************Empoderamiento***************************************************************************/
{
use "Encuesta Hogares URT_corregida", clear
*Toma de decisiones
	recode m3_* (1=3) (2 5=1) (3 4=2) (99=.) (6=.)
	egen decisiones= rowmean(m3_* )
	replace decisiones =(decisiones-1)/(3-1) 
	replace decisiones =decisiones*100
	label var decisiones "índice de independencia en la toma de decisiones"
*Rol de género
	recode m4_c ///
		m4_d m4_e m4_f (5=1) (4=2) (2=4) (1=5)
	recode m4_* (99=.) (6=.)	
	egen escalRoles= rowmean(m4_*)
	replace escalRoles=(escalRoles-1)/4
	replace escalRoles=escalRoles*100
	label var escalRoles "Escala de roles de género dentro del hogar"
}
/********************************************************Medias y estadísticas********************************************************************/
{
use "Encuesta Hogares URT_corregida", clear
global descrip personas_hogar ingRent ingAyuFam ingPenDivo ingAgro ingNoAgro ingMFApam ingOtros ingTotal pobreza dummy_pobreza ahorPreFormal ///
	ahorPreInformal credPreFormal credPreInformal presen_huerta escBnstar aspBnstar5 expBnstar5 aspBnstar2 expBnstar2 lagAsp5 ///
	lagExp5 lagAsp2 lagExp2 decisiones escalRoles

**Pruebas de medias Graduados vs Activos**
foreach var of global descrip {
reg `var' participante
sum `var' if participante == 1 & e(sample)
local m1 = r(mean) 
local m2 = r(sd) 
sum `var' if participante == 0 & e(sample)
local m3 = r(mean) 
local m4 = r(sd) 
outreg2 using "diff_URT2.xls", addstat("Media1",`m1',"Media2",`m3', "sd1",`m2',"sd2",`m4') ctitle("`var'")
}
**Medias por año de deseembolso**
merge 1:1 numero_hogar using "Lista precargada urt.dta"
keep if _merge !=2
foreach var of global descrip {
reg `var' year*, nocons
outreg2 using "medias_URT2.xls"
}

foreach var of global descrip {
forvalues ano=2015(1)2018{
estpost summarize `var' if año_desembolso== `ano'. 

esttab using "medias_URT3.tex", cells("mean(fmt(3)) sd(fmt(3))") label append  noobs

}
}

}
/********************************************************Tablas de indicadores********************************************************************/
{
*Variables discretas*
foreach X of var {
eststo clear
eststo: estpost tabulate `X' , m
local labelvar=e(labels)
local label : variable label `X'
count if `X'==.
if r(N)>0 {
bys participante: eststo: estpost tabulate `X' , m 
esttab using "Tablas y gráficas\indicadores2.rtf", /*
*/ cells("b(label(Freq)) pct(label(Perc) fmt(1)) cumpct(label(Cum.) fmt(1))") /*
*/ modelwidth(7)  mtitle("Todo" "C" "F" "AB" "DE") varlabels(`labelvar')/*
*/ append nonumber title(Variable - `X') 
} 
else {
bys grupos: eststo: estpost tabulate `X' , m
esttab using "C:\Users\a.romero11\OneDrive\CEDE\Encuesta de Hogares de Colombia\Encuesta Completa\Tablas y gráficas\indicadores2.rtf", /*
*/ cells("b(label(Freq)) pct(label(Perc) fmt(1)) cumpct(label(Cum.) fmt(1))") /*
*/ modelwidth(7)  mtitle("Todo" "C" "F" "AB" "DE")/*
*/ append nonumber title(Variable - `X') 
}
}
*Variables continuas*
foreach X of var {
preserve
	gen `X'_G=`X' if participante==0
	gen `X'_A=`X' if participante==1
	eststo clear
	eststo: estpost tabstat `X' `X'_G `X'_A, s(count mean sd min max p1 p5 p10 p25 med p75 p90 p95 p99) c(v)
	local label : variable label `X' 
	esttab using "C:\Users\a.romero11\OneDrive\CEDE\Encuesta de Hogares de Colombia\Encuesta Completa\Tablas y gráficas\indicadores66.rtf", ///
	c("`X'(label(Todos) fmt(%10.2gc)) `X'_G(label(Graduados) fmt(%10.2gc)) `X'_A(label(Activos) fmt(%10.2gc))") ///
	nonum nomtitle title(Variable - `X' - `label') append
restore
}
}
