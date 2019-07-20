# rOS_Failover
Configura Mikrotik para multi WAN + balanceo + failover sobre WIFI_ETECSA

Este script te permite configurar tu MikroTik (si tiene licencia L4) para hacer multi WAN (lo que se conoce como multiportales) además, ofrece balanceo para los usuarios (IP) que pertenezcan a la lista "Wetecsa1" incluyendo failover sobre las interfaces.

<b>Como usar el script:</b>
<b>Primero lo primero: Bajar el script y editarlo para configurar las variables necesarias según la descripción.</b>

:global ifaces 8; ---->>>>> es la cantidad de interfaces que queremos conectar a WIFI_ETECSA incluyendo la interfaz física del equipo (cambiar el 8 por la cantidad de interfaces deseadas).

:global mIface "Wetecsa1"; ---->>>>> es el nombre que le daremos a la interfaz inalámbrica física (puedes cambiarlo o dejarlo asi... solo cambia lo que está entre "") <b>Antes de comenzar a pegar el script en el MikroTik hay que cambiar el nombre de la interfaz inalámbrica física por el nombre que le demos a esta variable</b>

:global prefix "Wetecsa"; ---->>>>>> es el prefijo que tendrán las interfaces, tener en cuenta que el prefijo tiene que ser el mismo de la variable mIface sin el número (cambiar solo lo que está entre "").

:global gw 10.204.10.1; ----->>>>>>> es el gateway/puerta de enlace que les asigna ETECSA. Este IP varía así que deben averiguar primero cual es (cambiar solo el IP).

:global ssid "WIFI_ETECSA" --->>>>>> por su puesto este es el SSID de los AP de ETECSA. Si te conectas a traves de un hotel u otro establecimiento que tenga otro nombre puedes cambiarlo (solo lo que esta entre "").

<b>Te recomiendo usar el video como guía luego de haber editado el script y configurado las variables.</b>
<b>Video:<b> https://youtu.be/UvgebCWrY4c
