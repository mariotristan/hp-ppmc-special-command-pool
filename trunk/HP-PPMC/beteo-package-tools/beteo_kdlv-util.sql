
  CREATE OR REPLACE PACKAGE "PPMC"."BETEO_KDLV_UTIL" IS

  /*
  * Package Name: BETEO_kdlv_util
  *
  *        Zweck: Dieses PL/SQL-Package enth?lt Hilfsfunktionen zum Umgang mit
  *               Kintana Deliver (Version 4.6); vor allem zum Umgang mit dem
  *               Open Interface zur Erzeugung von Packages.
  *
  *        Autor: Torsten Neumann, BETEO Deutschland GmbH
  *        Datum: 10.03.2003
  *
  * Historie
  * Datum        Autor             Beschreibung
  * *************************************************************************
  * 10.03.2003   Torsten Neumann   Initiale Implementierung f?r Kintana 4.6
  * 07.10.2003   Torsten Neumann   create_pkg_from_req() hinzugef?gt
  * 21.10.2003   Torsten Neumann   added add_pkg_to_rel()
  * 05.01.2004   Torsten Neumann   added run_next_pkgl()
  * 19.01.2006   Torsten Neumann   add_package_line_existing() now auto-creates
  *                                entry in KDLV_PACKAGES_INT table.
  * 24.01.2006   Torsten Neumann   added add_request_to_rel() to add a request
  *                                to a release
  * 21.02.2006   Torsten Neumann   added subworkflow support to create_pkg_from_req()
  * 22.02.2006   Torsten Neumann   added p_appcode parameter to add_package_line_existing()
  *
  * $Id: BETEO_kdlv_util.pck,v 6.1 2006/02/23 21:33:54 tor_neu Exp $
  *
  */

  /*
  * Die Funktion add_package() f?gt eine Zeile in die Open Interface-Tabelle
  * KDLV_PACKAGES_INT ein.
  *
  * Bei Erfolg gibt die Funktion den String 'SUCCESS' zur?ck, ansonsten 'FAILURE'.
  *
  */
  FUNCTION add_package(p_package_interface_id   IN OUT kdlv_packages_int.package_interface_id%TYPE
                      ,p_group_id               IN OUT kdlv_packages_int.group_id%TYPE
                      ,p_created_by_username    IN kdlv_packages_int.created_by_username%TYPE DEFAULT NULL
                      ,p_creation_date          IN kdlv_packages_int.creation_date%TYPE DEFAULT NULL
                      ,p_source_code            IN kdlv_packages_int.source_code%TYPE DEFAULT NULL
                      ,p_package_id             OUT kdlv_packages_int.package_id%TYPE
                      ,p_requested_by_username  IN kdlv_packages_int.requested_by_username%TYPE
                      ,p_assigned_to_username   IN kdlv_packages_int.assigned_to_username%TYPE DEFAULT NULL
                      ,p_assigned_to_group_name IN kdlv_packages_int.assigned_to_group_name%TYPE DEFAULT NULL
                      ,p_description            IN kdlv_packages_int.description%TYPE DEFAULT NULL
                      ,p_workflow_name          IN kdlv_packages_int.workflow_name%TYPE
                      ,p_release_flag           IN kdlv_packages_int.release_flag%TYPE DEFAULT 'Y'
                      ,p_package_group_code     IN kdlv_packages_int.project_code%TYPE DEFAULT NULL
                      ,p_package_type_code      IN kdlv_packages_int.package_type_code%TYPE DEFAULT NULL
                      ,p_priority_code          IN kdlv_packages_int.priority_code%TYPE DEFAULT NULL
                      ,p_user_data1             IN kdlv_packages_int.user_data1%TYPE DEFAULT NULL
                      ,p_visible_user_data1     IN kdlv_packages_int.visible_user_data1%TYPE DEFAULT NULL
                      ,p_user_data2             IN kdlv_packages_int.user_data2%TYPE DEFAULT NULL
                      ,p_visible_user_data2     IN kdlv_packages_int.visible_user_data2%TYPE DEFAULT NULL
                      ,p_user_data3             IN kdlv_packages_int.user_data3%TYPE DEFAULT NULL
                      ,p_visible_user_data3     IN kdlv_packages_int.visible_user_data3%TYPE DEFAULT NULL
                      ,p_user_data4             IN kdlv_packages_int.user_data4%TYPE DEFAULT NULL
                      ,p_visible_user_data4     IN kdlv_packages_int.visible_user_data4%TYPE DEFAULT NULL
                      ,p_user_data5             IN kdlv_packages_int.user_data5%TYPE DEFAULT NULL
                      ,p_visible_user_data5     IN kdlv_packages_int.visible_user_data5%TYPE DEFAULT NULL
                      ,p_user_data6             IN kdlv_packages_int.user_data6%TYPE DEFAULT NULL
                      ,p_visible_user_data6     IN kdlv_packages_int.visible_user_data6%TYPE DEFAULT NULL
                      ,p_user_data7             IN kdlv_packages_int.user_data7%TYPE DEFAULT NULL
                      ,p_visible_user_data7     IN kdlv_packages_int.visible_user_data7%TYPE DEFAULT NULL
                      ,p_user_data8             IN kdlv_packages_int.user_data8%TYPE DEFAULT NULL
                      ,p_visible_user_data8     IN kdlv_packages_int.visible_user_data8%TYPE DEFAULT NULL
                      ,p_user_data9             IN kdlv_packages_int.user_data9%TYPE DEFAULT NULL
                      ,p_visible_user_data9     IN kdlv_packages_int.visible_user_data9%TYPE DEFAULT NULL
                      ,p_user_data10            IN kdlv_packages_int.user_data10%TYPE DEFAULT NULL
                      ,p_visible_user_data10    IN kdlv_packages_int.visible_user_data10%TYPE DEFAULT NULL
                      ,p_user_data11            IN kdlv_packages_int.user_data11%TYPE DEFAULT NULL
                      ,p_visible_user_data11    IN kdlv_packages_int.visible_user_data11%TYPE DEFAULT NULL
                      ,p_user_data12            IN kdlv_packages_int.user_data12%TYPE DEFAULT NULL
                      ,p_visible_user_data12    IN kdlv_packages_int.visible_user_data12%TYPE DEFAULT NULL
                      ,p_user_data13            IN kdlv_packages_int.user_data13%TYPE DEFAULT NULL
                      ,p_visible_user_data13    IN kdlv_packages_int.visible_user_data13%TYPE DEFAULT NULL
                      ,p_user_data14            IN kdlv_packages_int.user_data14%TYPE DEFAULT NULL
                      ,p_visible_user_data14    IN kdlv_packages_int.visible_user_data14%TYPE DEFAULT NULL
                      ,p_user_data15            IN kdlv_packages_int.user_data15%TYPE DEFAULT NULL
                      ,p_visible_user_data15    IN kdlv_packages_int.visible_user_data15%TYPE DEFAULT NULL
                      ,p_user_data16            IN kdlv_packages_int.user_data16%TYPE DEFAULT NULL
                      ,p_visible_user_data16    IN kdlv_packages_int.visible_user_data16%TYPE DEFAULT NULL
                      ,p_user_data17            IN kdlv_packages_int.user_data17%TYPE DEFAULT NULL
                      ,p_visible_user_data17    IN kdlv_packages_int.visible_user_data17%TYPE DEFAULT NULL
                      ,p_user_data18            IN kdlv_packages_int.user_data18%TYPE DEFAULT NULL
                      ,p_visible_user_data18    IN kdlv_packages_int.visible_user_data18%TYPE DEFAULT NULL
                      ,p_user_data19            IN kdlv_packages_int.user_data19%TYPE DEFAULT NULL
                      ,p_visible_user_data19    IN kdlv_packages_int.visible_user_data19%TYPE DEFAULT NULL
                      ,p_user_data20            IN kdlv_packages_int.user_data20%TYPE DEFAULT NULL
                      ,p_visible_user_data20    IN kdlv_packages_int.visible_user_data20%TYPE DEFAULT NULL)
    RETURN VARCHAR2;

  /*
  * Die Funktion add_package_line() f?gt eine Zeile in die Open Interface-Tabelle
  * KDLV_PACKAGE_LINES_INT ein.
  *
  * Bei Erfolg gibt die Funktion den String 'SUCCESS' zur?ck, ansonsten 'FAILURE'.
  *
  */
  FUNCTION add_package_line(p_package_interface_id IN kdlv_package_lines_int.package_interface_id%TYPE
                           ,p_group_id             IN kdlv_package_lines_int.group_id%TYPE
                           ,p_package_id           IN kdlv_package_lines_int.package_id%TYPE
                           ,p_created_by_username  IN kdlv_package_lines_int.created_by_username%TYPE DEFAULT NULL
                           ,p_creation_date        IN kdlv_package_lines_int.creation_date%TYPE DEFAULT NULL
                           ,p_source_code          IN kdlv_package_lines_int.source_code%TYPE DEFAULT NULL
                           ,p_object_type_name     IN kdlv_package_lines_int.object_type_name%TYPE
                           ,p_object_name          IN kdlv_package_lines_int.object_name%TYPE
                           ,p_release_flag         IN kdlv_package_lines_int.release_flag%TYPE DEFAULT 'Y'
                           ,p_parameter1           IN kdlv_package_lines_int.PARAMETER1%TYPE DEFAULT NULL
                           ,p_visible_parameter1   IN kdlv_package_lines_int.VISIBLE_PARAMETER1%TYPE DEFAULT NULL
                           ,p_parameter2           IN kdlv_package_lines_int.PARAMETER2%TYPE DEFAULT NULL
                           ,p_visible_parameter2   IN kdlv_package_lines_int.VISIBLE_PARAMETER2%TYPE DEFAULT NULL
                           ,p_parameter3           IN kdlv_package_lines_int.PARAMETER3%TYPE DEFAULT NULL
                           ,p_visible_parameter3   IN kdlv_package_lines_int.VISIBLE_PARAMETER3%TYPE DEFAULT NULL
                           ,p_parameter4           IN kdlv_package_lines_int.PARAMETER4%TYPE DEFAULT NULL
                           ,p_visible_parameter4   IN kdlv_package_lines_int.VISIBLE_PARAMETER4%TYPE DEFAULT NULL
                           ,p_parameter5           IN kdlv_package_lines_int.PARAMETER5%TYPE DEFAULT NULL
                           ,p_visible_parameter5   IN kdlv_package_lines_int.VISIBLE_PARAMETER5%TYPE DEFAULT NULL
                           ,p_parameter6           IN kdlv_package_lines_int.PARAMETER6%TYPE DEFAULT NULL
                           ,p_visible_parameter6   IN kdlv_package_lines_int.VISIBLE_PARAMETER6%TYPE DEFAULT NULL
                           ,p_parameter7           IN kdlv_package_lines_int.PARAMETER7%TYPE DEFAULT NULL
                           ,p_visible_parameter7   IN kdlv_package_lines_int.VISIBLE_PARAMETER7%TYPE DEFAULT NULL
                           ,p_parameter8           IN kdlv_package_lines_int.PARAMETER8%TYPE DEFAULT NULL
                           ,p_visible_parameter8   IN kdlv_package_lines_int.VISIBLE_PARAMETER8%TYPE DEFAULT NULL
                           ,p_parameter9           IN kdlv_package_lines_int.PARAMETER9%TYPE DEFAULT NULL
                           ,p_visible_parameter9   IN kdlv_package_lines_int.VISIBLE_PARAMETER9%TYPE DEFAULT NULL
                           ,p_parameter10          IN kdlv_package_lines_int.PARAMETER10%TYPE DEFAULT NULL
                           ,p_visible_parameter10  IN kdlv_package_lines_int.VISIBLE_PARAMETER10%TYPE DEFAULT NULL
                           ,p_parameter11          IN kdlv_package_lines_int.PARAMETER11%TYPE DEFAULT NULL
                           ,p_visible_parameter11  IN kdlv_package_lines_int.VISIBLE_PARAMETER11%TYPE DEFAULT NULL
                           ,p_parameter12          IN kdlv_package_lines_int.PARAMETER12%TYPE DEFAULT NULL
                           ,p_visible_parameter12  IN kdlv_package_lines_int.VISIBLE_PARAMETER12%TYPE DEFAULT NULL
                           ,p_parameter13          IN kdlv_package_lines_int.PARAMETER13%TYPE DEFAULT NULL
                           ,p_visible_parameter13  IN kdlv_package_lines_int.VISIBLE_PARAMETER13%TYPE DEFAULT NULL
                           ,p_parameter14          IN kdlv_package_lines_int.PARAMETER14%TYPE DEFAULT NULL
                           ,p_visible_parameter14  IN kdlv_package_lines_int.VISIBLE_PARAMETER14%TYPE DEFAULT NULL
                           ,p_parameter15          IN kdlv_package_lines_int.PARAMETER15%TYPE DEFAULT NULL
                           ,p_visible_parameter15  IN kdlv_package_lines_int.VISIBLE_PARAMETER15%TYPE DEFAULT NULL
                           ,p_parameter16          IN kdlv_package_lines_int.PARAMETER16%TYPE DEFAULT NULL
                           ,p_visible_parameter16  IN kdlv_package_lines_int.VISIBLE_PARAMETER16%TYPE DEFAULT NULL
                           ,p_parameter17          IN kdlv_package_lines_int.PARAMETER17%TYPE DEFAULT NULL
                           ,p_visible_parameter17  IN kdlv_package_lines_int.VISIBLE_PARAMETER17%TYPE DEFAULT NULL
                           ,p_parameter18          IN kdlv_package_lines_int.PARAMETER18%TYPE DEFAULT NULL
                           ,p_visible_parameter18  IN kdlv_package_lines_int.VISIBLE_PARAMETER18%TYPE DEFAULT NULL
                           ,p_parameter19          IN kdlv_package_lines_int.PARAMETER19%TYPE DEFAULT NULL
                           ,p_visible_parameter19  IN kdlv_package_lines_int.VISIBLE_PARAMETER19%TYPE DEFAULT NULL
                           ,p_parameter20          IN kdlv_package_lines_int.PARAMETER20%TYPE DEFAULT NULL
                           ,p_visible_parameter20  IN kdlv_package_lines_int.VISIBLE_PARAMETER20%TYPE DEFAULT NULL
                           ,p_parameter21          IN kdlv_package_lines_int.PARAMETER21%TYPE DEFAULT NULL
                           ,p_visible_parameter21  IN kdlv_package_lines_int.VISIBLE_PARAMETER21%TYPE DEFAULT NULL
                           ,p_parameter22          IN kdlv_package_lines_int.PARAMETER22%TYPE DEFAULT NULL
                           ,p_visible_parameter22  IN kdlv_package_lines_int.VISIBLE_PARAMETER22%TYPE DEFAULT NULL
                           ,p_parameter23          IN kdlv_package_lines_int.PARAMETER23%TYPE DEFAULT NULL
                           ,p_visible_parameter23  IN kdlv_package_lines_int.VISIBLE_PARAMETER23%TYPE DEFAULT NULL
                           ,p_parameter24          IN kdlv_package_lines_int.PARAMETER24%TYPE DEFAULT NULL
                           ,p_visible_parameter24  IN kdlv_package_lines_int.VISIBLE_PARAMETER24%TYPE DEFAULT NULL
                           ,p_parameter25          IN kdlv_package_lines_int.PARAMETER25%TYPE DEFAULT NULL
                           ,p_visible_parameter25  IN kdlv_package_lines_int.VISIBLE_PARAMETER25%TYPE DEFAULT NULL
                           ,p_parameter26          IN kdlv_package_lines_int.PARAMETER26%TYPE DEFAULT NULL
                           ,p_visible_parameter26  IN kdlv_package_lines_int.VISIBLE_PARAMETER26%TYPE DEFAULT NULL
                           ,p_parameter27          IN kdlv_package_lines_int.PARAMETER27%TYPE DEFAULT NULL
                           ,p_visible_parameter27  IN kdlv_package_lines_int.VISIBLE_PARAMETER27%TYPE DEFAULT NULL
                           ,p_parameter28          IN kdlv_package_lines_int.PARAMETER28%TYPE DEFAULT NULL
                           ,p_visible_parameter28  IN kdlv_package_lines_int.VISIBLE_PARAMETER28%TYPE DEFAULT NULL
                           ,p_parameter29          IN kdlv_package_lines_int.PARAMETER29%TYPE DEFAULT NULL
                           ,p_visible_parameter29  IN kdlv_package_lines_int.VISIBLE_PARAMETER29%TYPE DEFAULT NULL
                           ,p_parameter30          IN kdlv_package_lines_int.PARAMETER30%TYPE DEFAULT NULL
                           ,p_visible_parameter30  IN kdlv_package_lines_int.VISIBLE_PARAMETER30%TYPE DEFAULT NULL
                           ,p_user_data1           IN kdlv_package_lines_int.user_data1%TYPE DEFAULT NULL
                           ,p_visible_user_data1   IN kdlv_package_lines_int.visible_user_data1%TYPE DEFAULT NULL
                           ,p_user_data2           IN kdlv_package_lines_int.user_data2%TYPE DEFAULT NULL
                           ,p_visible_user_data2   IN kdlv_package_lines_int.visible_user_data2%TYPE DEFAULT NULL
                           ,p_user_data3           IN kdlv_package_lines_int.user_data3%TYPE DEFAULT NULL
                           ,p_visible_user_data3   IN kdlv_package_lines_int.visible_user_data3%TYPE DEFAULT NULL
                           ,p_user_data4           IN kdlv_package_lines_int.user_data4%TYPE DEFAULT NULL
                           ,p_visible_user_data4   IN kdlv_package_lines_int.visible_user_data4%TYPE DEFAULT NULL
                           ,p_user_data5           IN kdlv_package_lines_int.user_data5%TYPE DEFAULT NULL
                           ,p_visible_user_data5   IN kdlv_package_lines_int.visible_user_data5%TYPE DEFAULT NULL
                           ,p_user_data6           IN kdlv_package_lines_int.user_data6%TYPE DEFAULT NULL
                           ,p_visible_user_data6   IN kdlv_package_lines_int.visible_user_data6%TYPE DEFAULT NULL
                           ,p_user_data7           IN kdlv_package_lines_int.user_data7%TYPE DEFAULT NULL
                           ,p_visible_user_data7   IN kdlv_package_lines_int.visible_user_data7%TYPE DEFAULT NULL
                           ,p_user_data8           IN kdlv_package_lines_int.user_data8%TYPE DEFAULT NULL
                           ,p_visible_user_data8   IN kdlv_package_lines_int.visible_user_data8%TYPE DEFAULT NULL
                           ,p_user_data9           IN kdlv_package_lines_int.user_data9%TYPE DEFAULT NULL
                           ,p_visible_user_data9   IN kdlv_package_lines_int.visible_user_data9%TYPE DEFAULT NULL
                           ,p_user_data10          IN kdlv_package_lines_int.user_data10%TYPE DEFAULT NULL
                           ,p_visible_user_data10  IN kdlv_package_lines_int.visible_user_data10%TYPE DEFAULT NULL
                           ,p_user_data11          IN kdlv_package_lines_int.user_data11%TYPE DEFAULT NULL
                           ,p_visible_user_data11  IN kdlv_package_lines_int.visible_user_data11%TYPE DEFAULT NULL
                           ,p_user_data12          IN kdlv_package_lines_int.user_data12%TYPE DEFAULT NULL
                           ,p_visible_user_data12  IN kdlv_package_lines_int.visible_user_data12%TYPE DEFAULT NULL
                           ,p_user_data13          IN kdlv_package_lines_int.user_data13%TYPE DEFAULT NULL
                           ,p_visible_user_data13  IN kdlv_package_lines_int.visible_user_data13%TYPE DEFAULT NULL
                           ,p_user_data14          IN kdlv_package_lines_int.user_data14%TYPE DEFAULT NULL
                           ,p_visible_user_data14  IN kdlv_package_lines_int.visible_user_data14%TYPE DEFAULT NULL
                           ,p_user_data15          IN kdlv_package_lines_int.user_data15%TYPE DEFAULT NULL
                           ,p_visible_user_data15  IN kdlv_package_lines_int.visible_user_data15%TYPE DEFAULT NULL
                           ,p_user_data16          IN kdlv_package_lines_int.user_data16%TYPE DEFAULT NULL
                           ,p_visible_user_data16  IN kdlv_package_lines_int.visible_user_data16%TYPE DEFAULT NULL
                           ,p_user_data17          IN kdlv_package_lines_int.user_data17%TYPE DEFAULT NULL
                           ,p_visible_user_data17  IN kdlv_package_lines_int.visible_user_data17%TYPE DEFAULT NULL
                           ,p_user_data18          IN kdlv_package_lines_int.user_data18%TYPE DEFAULT NULL
                           ,p_visible_user_data18  IN kdlv_package_lines_int.visible_user_data18%TYPE DEFAULT NULL
                           ,p_user_data19          IN kdlv_package_lines_int.user_data19%TYPE DEFAULT NULL
                           ,p_visible_user_data19  IN kdlv_package_lines_int.visible_user_data19%TYPE DEFAULT NULL
                           ,p_user_data20          IN kdlv_package_lines_int.user_data20%TYPE DEFAULT NULL
                           ,p_visible_user_data20  IN kdlv_package_lines_int.visible_user_data20%TYPE DEFAULT NULL)
    RETURN VARCHAR2;

  /*
  * add_package_line_existing() adds a package line to the Kintana Open Interface
  * table for an existing package.
  *
  * #return Returns SUCCESS if package line was added successfully and FAILURE otherwise
  *
  */
  FUNCTION add_package_line_existing(p_group_id            IN kdlv_package_lines_int.group_id%TYPE
                                    ,p_package_id          IN kdlv_package_lines_int.package_id%TYPE
                                    ,p_created_by_username IN kdlv_package_lines_int.created_by_username%TYPE DEFAULT NULL
                                    ,p_creation_date       IN kdlv_package_lines_int.creation_date%TYPE DEFAULT NULL
                                    ,p_source_code         IN kdlv_package_lines_int.source_code%TYPE DEFAULT NULL
                                    ,p_object_type_name    IN kdlv_package_lines_int.object_type_name%TYPE
                                    ,p_object_name         IN kdlv_package_lines_int.object_name%TYPE
                                    ,p_release_flag        IN kdlv_package_lines_int.release_flag%TYPE DEFAULT 'Y'
                                    ,p_parameter1          IN kdlv_package_lines_int.PARAMETER1%TYPE DEFAULT NULL
                                    ,p_visible_parameter1  IN kdlv_package_lines_int.VISIBLE_PARAMETER1%TYPE DEFAULT NULL
                                    ,p_parameter2          IN kdlv_package_lines_int.PARAMETER2%TYPE DEFAULT NULL
                                    ,p_visible_parameter2  IN kdlv_package_lines_int.VISIBLE_PARAMETER2%TYPE DEFAULT NULL
                                    ,p_parameter3          IN kdlv_package_lines_int.PARAMETER3%TYPE DEFAULT NULL
                                    ,p_visible_parameter3  IN kdlv_package_lines_int.VISIBLE_PARAMETER3%TYPE DEFAULT NULL
                                    ,p_parameter4          IN kdlv_package_lines_int.PARAMETER4%TYPE DEFAULT NULL
                                    ,p_visible_parameter4  IN kdlv_package_lines_int.VISIBLE_PARAMETER4%TYPE DEFAULT NULL
                                    ,p_parameter5          IN kdlv_package_lines_int.PARAMETER5%TYPE DEFAULT NULL
                                    ,p_visible_parameter5  IN kdlv_package_lines_int.VISIBLE_PARAMETER5%TYPE DEFAULT NULL
                                    ,p_parameter6          IN kdlv_package_lines_int.PARAMETER6%TYPE DEFAULT NULL
                                    ,p_visible_parameter6  IN kdlv_package_lines_int.VISIBLE_PARAMETER6%TYPE DEFAULT NULL
                                    ,p_parameter7          IN kdlv_package_lines_int.PARAMETER7%TYPE DEFAULT NULL
                                    ,p_visible_parameter7  IN kdlv_package_lines_int.VISIBLE_PARAMETER7%TYPE DEFAULT NULL
                                    ,p_parameter8          IN kdlv_package_lines_int.PARAMETER8%TYPE DEFAULT NULL
                                    ,p_visible_parameter8  IN kdlv_package_lines_int.VISIBLE_PARAMETER8%TYPE DEFAULT NULL
                                    ,p_parameter9          IN kdlv_package_lines_int.PARAMETER9%TYPE DEFAULT NULL
                                    ,p_visible_parameter9  IN kdlv_package_lines_int.VISIBLE_PARAMETER9%TYPE DEFAULT NULL
                                    ,p_parameter10         IN kdlv_package_lines_int.PARAMETER10%TYPE DEFAULT NULL
                                    ,p_visible_parameter10 IN kdlv_package_lines_int.VISIBLE_PARAMETER10%TYPE DEFAULT NULL
                                    ,p_parameter11         IN kdlv_package_lines_int.PARAMETER11%TYPE DEFAULT NULL
                                    ,p_visible_parameter11 IN kdlv_package_lines_int.VISIBLE_PARAMETER11%TYPE DEFAULT NULL
                                    ,p_parameter12         IN kdlv_package_lines_int.PARAMETER12%TYPE DEFAULT NULL
                                    ,p_visible_parameter12 IN kdlv_package_lines_int.VISIBLE_PARAMETER12%TYPE DEFAULT NULL
                                    ,p_parameter13         IN kdlv_package_lines_int.PARAMETER13%TYPE DEFAULT NULL
                                    ,p_visible_parameter13 IN kdlv_package_lines_int.VISIBLE_PARAMETER13%TYPE DEFAULT NULL
                                    ,p_parameter14         IN kdlv_package_lines_int.PARAMETER14%TYPE DEFAULT NULL
                                    ,p_visible_parameter14 IN kdlv_package_lines_int.VISIBLE_PARAMETER14%TYPE DEFAULT NULL
                                    ,p_parameter15         IN kdlv_package_lines_int.PARAMETER15%TYPE DEFAULT NULL
                                    ,p_visible_parameter15 IN kdlv_package_lines_int.VISIBLE_PARAMETER15%TYPE DEFAULT NULL
                                    ,p_parameter16         IN kdlv_package_lines_int.PARAMETER16%TYPE DEFAULT NULL
                                    ,p_visible_parameter16 IN kdlv_package_lines_int.VISIBLE_PARAMETER16%TYPE DEFAULT NULL
                                    ,p_parameter17         IN kdlv_package_lines_int.PARAMETER17%TYPE DEFAULT NULL
                                    ,p_visible_parameter17 IN kdlv_package_lines_int.VISIBLE_PARAMETER17%TYPE DEFAULT NULL
                                    ,p_parameter18         IN kdlv_package_lines_int.PARAMETER18%TYPE DEFAULT NULL
                                    ,p_visible_parameter18 IN kdlv_package_lines_int.VISIBLE_PARAMETER18%TYPE DEFAULT NULL
                                    ,p_parameter19         IN kdlv_package_lines_int.PARAMETER19%TYPE DEFAULT NULL
                                    ,p_visible_parameter19 IN kdlv_package_lines_int.VISIBLE_PARAMETER19%TYPE DEFAULT NULL
                                    ,p_parameter20         IN kdlv_package_lines_int.PARAMETER20%TYPE DEFAULT NULL
                                    ,p_visible_parameter20 IN kdlv_package_lines_int.VISIBLE_PARAMETER20%TYPE DEFAULT NULL
                                    ,p_parameter21         IN kdlv_package_lines_int.PARAMETER21%TYPE DEFAULT NULL
                                    ,p_visible_parameter21 IN kdlv_package_lines_int.VISIBLE_PARAMETER21%TYPE DEFAULT NULL
                                    ,p_parameter22         IN kdlv_package_lines_int.PARAMETER22%TYPE DEFAULT NULL
                                    ,p_visible_parameter22 IN kdlv_package_lines_int.VISIBLE_PARAMETER22%TYPE DEFAULT NULL
                                    ,p_parameter23         IN kdlv_package_lines_int.PARAMETER23%TYPE DEFAULT NULL
                                    ,p_visible_parameter23 IN kdlv_package_lines_int.VISIBLE_PARAMETER23%TYPE DEFAULT NULL
                                    ,p_parameter24         IN kdlv_package_lines_int.PARAMETER24%TYPE DEFAULT NULL
                                    ,p_visible_parameter24 IN kdlv_package_lines_int.VISIBLE_PARAMETER24%TYPE DEFAULT NULL
                                    ,p_parameter25         IN kdlv_package_lines_int.PARAMETER25%TYPE DEFAULT NULL
                                    ,p_visible_parameter25 IN kdlv_package_lines_int.VISIBLE_PARAMETER25%TYPE DEFAULT NULL
                                    ,p_parameter26         IN kdlv_package_lines_int.PARAMETER26%TYPE DEFAULT NULL
                                    ,p_visible_parameter26 IN kdlv_package_lines_int.VISIBLE_PARAMETER26%TYPE DEFAULT NULL
                                    ,p_parameter27         IN kdlv_package_lines_int.PARAMETER27%TYPE DEFAULT NULL
                                    ,p_visible_parameter27 IN kdlv_package_lines_int.VISIBLE_PARAMETER27%TYPE DEFAULT NULL
                                    ,p_parameter28         IN kdlv_package_lines_int.PARAMETER28%TYPE DEFAULT NULL
                                    ,p_visible_parameter28 IN kdlv_package_lines_int.VISIBLE_PARAMETER28%TYPE DEFAULT NULL
                                    ,p_parameter29         IN kdlv_package_lines_int.PARAMETER29%TYPE DEFAULT NULL
                                    ,p_visible_parameter29 IN kdlv_package_lines_int.VISIBLE_PARAMETER29%TYPE DEFAULT NULL
                                    ,p_parameter30         IN kdlv_package_lines_int.PARAMETER30%TYPE DEFAULT NULL
                                    ,p_visible_parameter30 IN kdlv_package_lines_int.VISIBLE_PARAMETER30%TYPE DEFAULT NULL
                                    ,p_user_data1          IN kdlv_package_lines_int.user_data1%TYPE DEFAULT NULL
                                    ,p_visible_user_data1  IN kdlv_package_lines_int.visible_user_data1%TYPE DEFAULT NULL
                                    ,p_user_data2          IN kdlv_package_lines_int.user_data2%TYPE DEFAULT NULL
                                    ,p_visible_user_data2  IN kdlv_package_lines_int.visible_user_data2%TYPE DEFAULT NULL
                                    ,p_user_data3          IN kdlv_package_lines_int.user_data3%TYPE DEFAULT NULL
                                    ,p_visible_user_data3  IN kdlv_package_lines_int.visible_user_data3%TYPE DEFAULT NULL
                                    ,p_user_data4          IN kdlv_package_lines_int.user_data4%TYPE DEFAULT NULL
                                    ,p_visible_user_data4  IN kdlv_package_lines_int.visible_user_data4%TYPE DEFAULT NULL
                                    ,p_user_data5          IN kdlv_package_lines_int.user_data5%TYPE DEFAULT NULL
                                    ,p_visible_user_data5  IN kdlv_package_lines_int.visible_user_data5%TYPE DEFAULT NULL
                                    ,p_user_data6          IN kdlv_package_lines_int.user_data6%TYPE DEFAULT NULL
                                    ,p_visible_user_data6  IN kdlv_package_lines_int.visible_user_data6%TYPE DEFAULT NULL
                                    ,p_user_data7          IN kdlv_package_lines_int.user_data7%TYPE DEFAULT NULL
                                    ,p_visible_user_data7  IN kdlv_package_lines_int.visible_user_data7%TYPE DEFAULT NULL
                                    ,p_user_data8          IN kdlv_package_lines_int.user_data8%TYPE DEFAULT NULL
                                    ,p_visible_user_data8  IN kdlv_package_lines_int.visible_user_data8%TYPE DEFAULT NULL
                                    ,p_user_data9          IN kdlv_package_lines_int.user_data9%TYPE DEFAULT NULL
                                    ,p_visible_user_data9  IN kdlv_package_lines_int.visible_user_data9%TYPE DEFAULT NULL
                                    ,p_user_data10         IN kdlv_package_lines_int.user_data10%TYPE DEFAULT NULL
                                    ,p_visible_user_data10 IN kdlv_package_lines_int.visible_user_data10%TYPE DEFAULT NULL
                                    ,p_user_data11         IN kdlv_package_lines_int.user_data11%TYPE DEFAULT NULL
                                    ,p_visible_user_data11 IN kdlv_package_lines_int.visible_user_data11%TYPE DEFAULT NULL
                                    ,p_user_data12         IN kdlv_package_lines_int.user_data12%TYPE DEFAULT NULL
                                    ,p_visible_user_data12 IN kdlv_package_lines_int.visible_user_data12%TYPE DEFAULT NULL
                                    ,p_user_data13         IN kdlv_package_lines_int.user_data13%TYPE DEFAULT NULL
                                    ,p_visible_user_data13 IN kdlv_package_lines_int.visible_user_data13%TYPE DEFAULT NULL
                                    ,p_user_data14         IN kdlv_package_lines_int.user_data14%TYPE DEFAULT NULL
                                    ,p_visible_user_data14 IN kdlv_package_lines_int.visible_user_data14%TYPE DEFAULT NULL
                                    ,p_user_data15         IN kdlv_package_lines_int.user_data15%TYPE DEFAULT NULL
                                    ,p_visible_user_data15 IN kdlv_package_lines_int.visible_user_data15%TYPE DEFAULT NULL
                                    ,p_user_data16         IN kdlv_package_lines_int.user_data16%TYPE DEFAULT NULL
                                    ,p_visible_user_data16 IN kdlv_package_lines_int.visible_user_data16%TYPE DEFAULT NULL
                                    ,p_user_data17         IN kdlv_package_lines_int.user_data17%TYPE DEFAULT NULL
                                    ,p_visible_user_data17 IN kdlv_package_lines_int.visible_user_data17%TYPE DEFAULT NULL
                                    ,p_user_data18         IN kdlv_package_lines_int.user_data18%TYPE DEFAULT NULL
                                    ,p_visible_user_data18 IN kdlv_package_lines_int.visible_user_data18%TYPE DEFAULT NULL
                                    ,p_user_data19         IN kdlv_package_lines_int.user_data19%TYPE DEFAULT NULL
                                    ,p_visible_user_data19 IN kdlv_package_lines_int.visible_user_data19%TYPE DEFAULT NULL
                                    ,p_user_data20         IN kdlv_package_lines_int.user_data20%TYPE DEFAULT NULL
                                    ,p_visible_user_data20 IN kdlv_package_lines_int.visible_user_data20%TYPE DEFAULT NULL
                                    ,p_app_code            IN kdlv_package_lines_int.app_code%TYPE DEFAULT NULL)
    RETURN VARCHAR2;

  FUNCTION run_package_interface(p_group_id IN NUMBER
                                ,p_username IN VARCHAR2) RETURN VARCHAR2;

  /*
  * Function CREATE_REF_REQUEST_PACKAGE creates a reference between an existing request
  * and an existing package.
  *
  * Returns:
  *   'SUCCESS' if reference could be created
  *   'FAILURE' if reference could not be created
  */
  FUNCTION create_ref_request_package(p_parent_request_id IN kcrt_requests.request_id%TYPE
                                     ,p_child_package_id  IN kdlv_packages.package_id%TYPE)
    RETURN VARCHAR2;

  /*
  * Function submit_Package() starts the workflow for the package with the package ID given
  * in parameter p_package_id.
  *
  * Returns:
  *   'SUCCESS' if package was successfully submitted
  *   'FAILURE' otherwise
  */
  FUNCTION submit_package(p_package_id IN kdlv_packages.package_id%TYPE
                         ,p_username   IN kwfl_transactions_int.created_username%TYPE)
    RETURN VARCHAR2;

  /*
  * Function create_pkg_from_req() performs the same function as the Kintana standard
  * workflow step source "Create Package". You can create a package from a request
  * workflow and the package is automatically referenced in the request. The main advantage
  * of this function is that it can be executed fully automatic - no manual interaction is
  * needed to provide workflow details etc. Packages created by this function can be used
  * to implement Jump/Receive.
  *
  * Parameter:
  *    p_source_request_id      Request id of the Kintana request from which the
  *                             package is created
  *    p_source_wf_step_id      Workflow step id from the request workflow step from
  *                             which this function is called (usually [WFS.WORKFLOW_STEP_ID])
  *
  * Returns:
  *    'SUCCESS' if package was successfully created and linked to the request
  *              package id can be found in o_package_id
  *    'FAILURE' otherwise
  *              error message can be found in o_message
  */
  FUNCTION create_pkg_from_req(p_source_request_id      IN kcrt_requests.request_id%TYPE
                              ,p_source_wf_step_id      IN kwfl_workflow_steps.workflow_step_id%TYPE
                              ,p_created_by_username    IN knta_users.username%TYPE
                              ,p_workflow_name          IN kwfl_workflows.workflow_name%TYPE
                              ,p_description            IN kdlv_packages.description%TYPE
                              ,p_priority_code          IN kdlv_packages.priority_code%TYPE DEFAULT 'NORMAL'
                              ,p_priority_seq           IN kdlv_packages.priority_seq%TYPE DEFAULT 50
                              ,p_assigned_to_username   IN knta_users.username%TYPE DEFAULT NULL
                              ,p_assigned_to_group_name IN knta_security_groups.security_group_name%TYPE DEFAULT NULL
                              ,p_package_type           IN kdlv_packages.package_type_code%TYPE DEFAULT NULL
                              ,p_package_group          IN kdlv_packages.project_code%TYPE DEFAULT NULL
                              ,o_package_id             OUT kdlv_packages.package_id%TYPE
                              ,o_message                OUT VARCHAR2)
    RETURN VARCHAR2;

  /*
  * Function add_pkg_to_rel() adds a Kintana package to an existing Kintana release.
  *
  * Parameter:
  *    p_package_id          The package with this id will be added to the release
  *    p_release_name        Displayed name of the release the package will be added to
  *    p_added_by_username  Name of the Kintana user who added the package to the release
  *
  * Returns:
  *    'SUCCESS' if package was successfully linked to the release
  *    'FAILURE' otherwise
  *              error message can be found in o_message
  */
  FUNCTION add_pkg_to_rel(p_package_id        IN kdlv_packages.package_id%TYPE
                         ,p_release_id        IN krel_releases.release_id%TYPE
                         ,p_added_by_username IN knta_users.username%TYPE
                         ,o_message           OUT VARCHAR2) RETURN VARCHAR2;

  /*
  * Function add_request_to_rel() adds a Kintana request to an existing Kintana release.
  *
  * Parameter:
  *    p_request_id          The request with this id will be added to the release
  *    p_release_name        Displayed name of the release the package will be added to
  *    p_added_by_username  Name of the Kintana user who added the package to the release
  *
  * Returns:
  *    'SUCCESS' if request was successfully linked to the release
  *    'FAILURE' otherwise
  *              error message can be found in o_message
  */
  FUNCTION add_request_to_rel(p_request_id        IN kcrt_requests.request_id%TYPE
                             ,p_release_id        IN krel_releases.release_id%TYPE
                             ,p_added_by_username IN knta_users.username%TYPE
                             ,o_message           OUT VARCHAR2)
    RETURN VARCHAR2;

  /*
  * Function run_next_pkgl() can be used to run package lines in sequential order.
  * The function checks whether there are further package lines to run and starts
  * the next package line in sequential order, if one is found. The package line to be run
  * must be on a decision workflow step.
  *
  * Parameter:
  *    p_package_id            The package containing the lines to be run
  *    p_package_line_seq      The sequence number of the current package line (usually [PKGL.SEQ])
  *    p_workflow_step_seq     The sequence number of the workflow step the target line is staying at
  *    p_visible_result_value  The outcome of the decision step the workflow should use
  *    o_message               Message text with further information on errors or warnings
  *
  * Returns:
  *    'SUCCESS'  if no further package line exists or if the next line was started successfully
  *    'FAILURE'  if the next package line could not be started
  */
  FUNCTION run_next_pkgl(p_package_id           IN kdlv_packages.package_id%TYPE
                        ,p_package_line_seq     IN kdlv_package_lines.seq%TYPE
                        ,p_workflow_step_seq    IN kwfl_workflow_steps.sort_order%TYPE
                        ,p_visible_result_value IN kwfl_step_transitions.visible_result_value%TYPE
                        ,o_message              OUT VARCHAR2) RETURN VARCHAR2;

END BETEO_kdlv_util;
/
CREATE OR REPLACE PACKAGE BODY "PPMC"."BETEO_KDLV_UTIL" IS

  /*
  * Package Name: BETEO_kdlv_util
  *
  *        Zweck: Dieses PL/SQL-Package enth?lt Hilfsfunktionen zum Umgang mit
  *               Kintana Deliver (Version 4.6); vor allem zum Umgang mit dem
  *               Open Interface zur Erzeugung von Packages.
  *
  *        Autor: Torsten Neumann, BETEO Deutschland GmbH
  *        Datum: 10.03.2003
  *
  * Historie
  * Datum        Autor             Beschreibung
  * *************************************************************************
  * 10.03.2003   Torsten Neumann   Initiale Implementierung f?r Kintana 4.6
  * 08.10.2003   Torsten Neumann   added create_pkg_from_req()
  * 21.10.2003   Torsten Neumann   added add_pkg_to_rel()
  * 05.01.2004   Torsten Neumann   added run_next_pkgl()
  * 07.11.2005   Torsten Neumann   removed references to RML schema
  *
  * $Id: BETEO_kdlv_util.pck,v 6.1 2006/02/23 21:33:54 tor_neu Exp $
  *
  */

  /*
  * Variablendeklarationen
  */
  g_success CONSTANT VARCHAR2(7) := 'SUCCESS';
  g_failure CONSTANT VARCHAR2(7) := 'FAILURE';

  g_sql_num NUMBER;
  g_sql_msg VARCHAR2(200);

  g_package_name CONSTANT VARCHAR2(20) := 'BETEO_KDLV_UTIL';

  APPLICATION_ERROR EXCEPTION;

  /*
  * Cursor-Definitionen
  */
  CURSOR c_get_errors(p_group_id NUMBER) IS
    SELECT kie.message_name, kie.message
      FROM knta_interface_errors kie
     WHERE kie.group_id = p_group_id AND message_type_id NOT IN (30); -- 30 ist eine Warnung

  CURSOR c_get_warnings(p_group_id NUMBER) IS
    SELECT kie.message_name, kie.message
      FROM knta_interface_errors kie
     WHERE kie.group_id = p_group_id AND message_type_id = 30; -- 30 ist eine Warnung

  /******************************************************************************************************
  * Internal Functions / Procedures                                                                    *
  ******************************************************************************************************
  */

  /*
  * Function get_validation_meaning() returns the meaning value for a validation code of
  * a validation validated by a drop down list. If no value could be retrieved, an error
  * message is placed in o_message and the return value is set to '***ERROR***'.
  */
  FUNCTION get_validation_meaning(p_validation_name IN knta_validations.validation_name%TYPE
                                 ,p_validation_code IN knta_lookups.lookup_code%TYPE
                                 ,o_message         OUT VARCHAR2)
    RETURN knta_lookups.meaning%TYPE IS
    l_return knta_lookups.meaning%TYPE;
  BEGIN
    SELECT l.meaning
      INTO l_return
      FROM knta_lookups l, knta_validations v
     WHERE l.lookup_code = p_validation_code AND
           v.validation_name = p_validation_name AND
           v.lookup_type = l.lookup_type AND v.validation_type_code = 'L';
    return l_return;

  EXCEPTION
    WHEN OTHERS THEN
      o_message := SQLCODE || ':' || SQLERRM;
      l_return  := '***ERROR***';
      return l_return;
  END get_validation_meaning;

  /*
  * Function get_security_group_id() returns the security group id of the given security group name
  * and -1 if the given security group does not exist.
  */
  FUNCTION get_security_group_id(p_security_group_name IN knta_security_groups.security_group_name%TYPE)
    RETURN knta_security_groups.security_group_id%TYPE IS
    l_security_group_id knta_security_groups.security_group_id%TYPE;
  BEGIN
    SELECT sg.security_group_id
      INTO l_security_group_id
      FROM knta_security_groups sg
     WHERE sg.security_group_name = p_security_group_name;
    return l_security_group_id;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR: SQL Error Code: ' || SQLCODE);
      dbms_output.put_line('ERROR: ' || SQLERRM);
      return - 1;
  END get_security_group_id;

  /*
  * Function get_user_id() returns the user id of the given user name
  * and -1 if the given user does not exist.
  */
  FUNCTION get_user_id(p_username IN knta_users.username%TYPE)
    RETURN knta_users.user_id%TYPE IS
    l_user_id knta_users.user_id%TYPE;
  BEGIN
    SELECT u.user_id
      INTO l_user_id
      FROM knta_users u
     WHERE u.username = p_username;
    return l_user_id;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR: SQL Error Code: ' || SQLCODE);
      dbms_output.put_line('ERROR: ' || SQLERRM);
      return - 1;
  END get_user_id;

  /*
  * Function get_workflow_id() returns the workflow id of the given workflow name
  * and -1 if the gievn workflow does not exist.
  */
  FUNCTION get_workflow_id(p_workflow_name IN kwfl_workflows.workflow_name%TYPE)
    RETURN kwfl_workflows.workflow_id%TYPE IS
    l_workflow_id kwfl_workflows.workflow_id%TYPE;
  BEGIN
    SELECT wf.workflow_id
      INTO l_workflow_id
      FROM kwfl_workflows wf
     WHERE wf.workflow_name = p_workflow_name;
    return l_workflow_id;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR: SQL Error Code: ' || SQLCODE);
      dbms_output.put_line('ERROR: ' || SQLERRM);
      return - 1;
  END get_workflow_id;

  /*
  * Function get_active_step_transaction_id() returns the step transaction id of the
  * active ('ELIGIBLE') instance of the workflow step identified by workflow step id and
  * request id.
  */
  FUNCTION get_active_step_transaction_id(p_request_id IN kcrt_requests.request_id%TYPE
                                         ,p_wf_step_id IN kwfl_workflow_steps.workflow_step_id%TYPE)
    RETURN kwfl_step_transactions.step_transaction_id%TYPE IS
    l_step_transaction_id kwfl_step_transactions.step_transaction_id%TYPE;
  BEGIN
    SELECT wst.step_transaction_id
      INTO l_step_transaction_id
      FROM kwfl_step_transactions wst
     WHERE wst.workflow_step_id = p_wf_step_id AND
          -- 21.02.2006 Commented out to support create package in sub-workflows
          --           wst.instance_source_type_code = 'IR' AND
          --           wst.instance_source_id = p_request_id AND
           wst.top_instance_source_type_code = 'IR' AND
           wst.top_instance_source_id = p_request_id AND
           wst.status = 'IN_PROGRESS';
    return l_step_transaction_id;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR: SQL Error Code: ' || SQLCODE);
      dbms_output.put_line('ERROR: ' || SQLERRM);
      return - 1;
  END get_active_step_transaction_id;

  /*
  * Funktionsdefinitionen
  */
  FUNCTION add_package(p_package_interface_id   IN OUT kdlv_packages_int.package_interface_id%TYPE
                      ,p_group_id               IN OUT kdlv_packages_int.group_id%TYPE
                      ,p_created_by_username    IN kdlv_packages_int.created_by_username%TYPE DEFAULT NULL
                      ,p_creation_date          IN kdlv_packages_int.creation_date%TYPE DEFAULT NULL
                      ,p_source_code            IN kdlv_packages_int.source_code%TYPE DEFAULT NULL
                      ,p_package_id             OUT kdlv_packages_int.package_id%TYPE
                      ,p_requested_by_username  IN kdlv_packages_int.requested_by_username%TYPE
                      ,p_assigned_to_username   IN kdlv_packages_int.assigned_to_username%TYPE DEFAULT NULL
                      ,p_assigned_to_group_name IN kdlv_packages_int.assigned_to_group_name%TYPE DEFAULT NULL
                      ,p_description            IN kdlv_packages_int.description%TYPE DEFAULT NULL
                      ,p_workflow_name          IN kdlv_packages_int.workflow_name%TYPE
                      ,p_release_flag           IN kdlv_packages_int.release_flag%TYPE DEFAULT 'Y'
                      ,p_package_group_code     IN kdlv_packages_int.project_code%TYPE DEFAULT NULL
                      ,p_package_type_code      IN kdlv_packages_int.package_type_code%TYPE DEFAULT NULL
                      ,p_priority_code          IN kdlv_packages_int.priority_code%TYPE DEFAULT NULL
                      ,p_user_data1             IN kdlv_packages_int.user_data1%TYPE DEFAULT NULL
                      ,p_visible_user_data1     IN kdlv_packages_int.visible_user_data1%TYPE DEFAULT NULL
                      ,p_user_data2             IN kdlv_packages_int.user_data2%TYPE DEFAULT NULL
                      ,p_visible_user_data2     IN kdlv_packages_int.visible_user_data2%TYPE DEFAULT NULL
                      ,p_user_data3             IN kdlv_packages_int.user_data3%TYPE DEFAULT NULL
                      ,p_visible_user_data3     IN kdlv_packages_int.visible_user_data3%TYPE DEFAULT NULL
                      ,p_user_data4             IN kdlv_packages_int.user_data4%TYPE DEFAULT NULL
                      ,p_visible_user_data4     IN kdlv_packages_int.visible_user_data4%TYPE DEFAULT NULL
                      ,p_user_data5             IN kdlv_packages_int.user_data5%TYPE DEFAULT NULL
                      ,p_visible_user_data5     IN kdlv_packages_int.visible_user_data5%TYPE DEFAULT NULL
                      ,p_user_data6             IN kdlv_packages_int.user_data6%TYPE DEFAULT NULL
                      ,p_visible_user_data6     IN kdlv_packages_int.visible_user_data6%TYPE DEFAULT NULL
                      ,p_user_data7             IN kdlv_packages_int.user_data7%TYPE DEFAULT NULL
                      ,p_visible_user_data7     IN kdlv_packages_int.visible_user_data7%TYPE DEFAULT NULL
                      ,p_user_data8             IN kdlv_packages_int.user_data8%TYPE DEFAULT NULL
                      ,p_visible_user_data8     IN kdlv_packages_int.visible_user_data8%TYPE DEFAULT NULL
                      ,p_user_data9             IN kdlv_packages_int.user_data9%TYPE DEFAULT NULL
                      ,p_visible_user_data9     IN kdlv_packages_int.visible_user_data9%TYPE DEFAULT NULL
                      ,p_user_data10            IN kdlv_packages_int.user_data10%TYPE DEFAULT NULL
                      ,p_visible_user_data10    IN kdlv_packages_int.visible_user_data10%TYPE DEFAULT NULL
                      ,p_user_data11            IN kdlv_packages_int.user_data11%TYPE DEFAULT NULL
                      ,p_visible_user_data11    IN kdlv_packages_int.visible_user_data11%TYPE DEFAULT NULL
                      ,p_user_data12            IN kdlv_packages_int.user_data12%TYPE DEFAULT NULL
                      ,p_visible_user_data12    IN kdlv_packages_int.visible_user_data12%TYPE DEFAULT NULL
                      ,p_user_data13            IN kdlv_packages_int.user_data13%TYPE DEFAULT NULL
                      ,p_visible_user_data13    IN kdlv_packages_int.visible_user_data13%TYPE DEFAULT NULL
                      ,p_user_data14            IN kdlv_packages_int.user_data14%TYPE DEFAULT NULL
                      ,p_visible_user_data14    IN kdlv_packages_int.visible_user_data14%TYPE DEFAULT NULL
                      ,p_user_data15            IN kdlv_packages_int.user_data15%TYPE DEFAULT NULL
                      ,p_visible_user_data15    IN kdlv_packages_int.visible_user_data15%TYPE DEFAULT NULL
                      ,p_user_data16            IN kdlv_packages_int.user_data16%TYPE DEFAULT NULL
                      ,p_visible_user_data16    IN kdlv_packages_int.visible_user_data16%TYPE DEFAULT NULL
                      ,p_user_data17            IN kdlv_packages_int.user_data17%TYPE DEFAULT NULL
                      ,p_visible_user_data17    IN kdlv_packages_int.visible_user_data17%TYPE DEFAULT NULL
                      ,p_user_data18            IN kdlv_packages_int.user_data18%TYPE DEFAULT NULL
                      ,p_visible_user_data18    IN kdlv_packages_int.visible_user_data18%TYPE DEFAULT NULL
                      ,p_user_data19            IN kdlv_packages_int.user_data19%TYPE DEFAULT NULL
                      ,p_visible_user_data19    IN kdlv_packages_int.visible_user_data19%TYPE DEFAULT NULL
                      ,p_user_data20            IN kdlv_packages_int.user_data20%TYPE DEFAULT NULL
                      ,p_visible_user_data20    IN kdlv_packages_int.visible_user_data20%TYPE DEFAULT NULL)
    RETURN VARCHAR2 IS
  BEGIN
    g_sql_num := 10;
    SELECT NVL(p_package_interface_id, kdlv_interfaces_s.nextval)
      INTO p_package_interface_id
      FROM sys.dual;

    g_sql_num := 20;
    SELECT NVL(p_group_id, knta_interface_groups_s.nextval)
      INTO p_group_id
      FROM sys.dual;

    g_sql_num := 30;
    SELECT kdlv_packages_s.nextval INTO p_package_id FROM sys.dual;

    g_sql_num := 40;
    INSERT INTO kdlv_packages_int
      (package_interface_id
      ,group_id
      ,process_phase
      ,process_status
      ,created_by_username
      ,creation_date
      ,source_code
      ,package_id
      ,requested_by_username
      ,package_number
      ,assigned_to_username
      ,assigned_to_group_name
      ,description
      ,workflow_name
      ,release_flag
      ,project_code
      ,package_type_code
      ,priority_code
      ,user_data1
      ,visible_user_data1
      ,user_data2
      ,visible_user_data2
      ,user_data3
      ,visible_user_data3
      ,user_data4
      ,visible_user_data4
      ,user_data5
      ,visible_user_data5
      ,user_data6
      ,visible_user_data6
      ,user_data7
      ,visible_user_data7
      ,user_data8
      ,visible_user_data8
      ,user_data9
      ,visible_user_data9
      ,user_data10
      ,visible_user_data10
      ,user_data11
      ,visible_user_data11
      ,user_data12
      ,visible_user_data12
      ,user_data13
      ,visible_user_data13
      ,user_data14
      ,visible_user_data14
      ,user_data15
      ,visible_user_data15
      ,user_data16
      ,visible_user_data16
      ,user_data17
      ,visible_user_data17
      ,user_data18
      ,visible_user_data18
      ,user_data19
      ,visible_user_data19
      ,user_data20
      ,visible_user_data20)
    VALUES
      (p_package_interface_id
      ,p_group_id
      ,1
      ,1
      ,p_created_by_username
      ,p_creation_date
      ,p_source_code
      ,p_package_id
      ,p_requested_by_username
      ,p_package_id
      ,p_assigned_to_username
      ,p_assigned_to_group_name
      ,p_description
      ,p_workflow_name
      ,p_release_flag
      ,p_package_group_code
      ,p_package_type_code
      ,p_priority_code
      ,NVL(p_user_data1, p_visible_user_data1)
      ,NVL(p_visible_user_data1, p_user_data1)
      ,NVL(p_user_data2, p_visible_user_data2)
      ,NVL(p_visible_user_data2, p_user_data2)
      ,NVL(p_user_data3, p_visible_user_data3)
      ,NVL(p_visible_user_data3, p_user_data3)
      ,NVL(p_user_data4, p_visible_user_data4)
      ,NVL(p_visible_user_data4, p_user_data4)
      ,NVL(p_user_data5, p_visible_user_data5)
      ,NVL(p_visible_user_data5, p_user_data5)
      ,NVL(p_user_data6, p_visible_user_data6)
      ,NVL(p_visible_user_data6, p_user_data6)
      ,NVL(p_user_data7, p_visible_user_data7)
      ,NVL(p_visible_user_data7, p_user_data7)
      ,NVL(p_user_data8, p_visible_user_data8)
      ,NVL(p_visible_user_data8, p_user_data8)
      ,NVL(p_user_data9, p_visible_user_data9)
      ,NVL(p_visible_user_data9, p_user_data9)
      ,NVL(p_user_data10, p_visible_user_data10)
      ,NVL(p_visible_user_data10, p_user_data10)
      ,NVL(p_user_data11, p_visible_user_data11)
      ,NVL(p_visible_user_data11, p_user_data11)
      ,NVL(p_user_data12, p_visible_user_data12)
      ,NVL(p_visible_user_data12, p_user_data12)
      ,NVL(p_user_data13, p_visible_user_data13)
      ,NVL(p_visible_user_data13, p_user_data13)
      ,NVL(p_user_data14, p_visible_user_data14)
      ,NVL(p_visible_user_data14, p_user_data14)
      ,NVL(p_user_data15, p_visible_user_data15)
      ,NVL(p_visible_user_data15, p_user_data15)
      ,NVL(p_user_data16, p_visible_user_data16)
      ,NVL(p_visible_user_data16, p_user_data16)
      ,NVL(p_user_data17, p_visible_user_data17)
      ,NVL(p_visible_user_data17, p_user_data17)
      ,NVL(p_user_data18, p_visible_user_data18)
      ,NVL(p_visible_user_data18, p_user_data18)
      ,NVL(p_user_data19, p_visible_user_data19)
      ,NVL(p_visible_user_data19, p_user_data19)
      ,NVL(p_user_data20, p_visible_user_data20)
      ,NVL(p_visible_user_data20, p_user_data20));

    RETURN g_success;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Exception in BETEO_kdlv_util.add_package()');
      dbms_output.put_line('SQL-Code: ' || SQLCODE);
      dbms_output.put_line(SQLERRM);
      RETURN g_failure;
  END add_package;

  /*
  * Die Funktion add_package_line() f?gt eine Zeile in die Open Interface-Tabelle
  * KDLV_PACKAGE_LINES_INT ein.
  *
  * Bei Erfolg gibt die Funktion den String 'SUCCESS' zur?ck, ansonsten 'FAILURE'.
  *
  */
  FUNCTION add_package_line(p_package_interface_id IN kdlv_package_lines_int.package_interface_id%TYPE
                           ,p_group_id             IN kdlv_package_lines_int.group_id%TYPE
                           ,p_package_id           IN kdlv_package_lines_int.package_id%TYPE
                           ,p_created_by_username  IN kdlv_package_lines_int.created_by_username%TYPE DEFAULT NULL
                           ,p_creation_date        IN kdlv_package_lines_int.creation_date%TYPE DEFAULT NULL
                           ,p_source_code          IN kdlv_package_lines_int.source_code%TYPE DEFAULT NULL
                           ,p_object_type_name     IN kdlv_package_lines_int.object_type_name%TYPE
                           ,p_object_name          IN kdlv_package_lines_int.object_name%TYPE
                           ,p_release_flag         IN kdlv_package_lines_int.release_flag%TYPE DEFAULT 'Y'
                           ,p_parameter1           IN kdlv_package_lines_int.PARAMETER1%TYPE DEFAULT NULL
                           ,p_visible_parameter1   IN kdlv_package_lines_int.VISIBLE_PARAMETER1%TYPE DEFAULT NULL
                           ,p_parameter2           IN kdlv_package_lines_int.PARAMETER2%TYPE DEFAULT NULL
                           ,p_visible_parameter2   IN kdlv_package_lines_int.VISIBLE_PARAMETER2%TYPE DEFAULT NULL
                           ,p_parameter3           IN kdlv_package_lines_int.PARAMETER3%TYPE DEFAULT NULL
                           ,p_visible_parameter3   IN kdlv_package_lines_int.VISIBLE_PARAMETER3%TYPE DEFAULT NULL
                           ,p_parameter4           IN kdlv_package_lines_int.PARAMETER4%TYPE DEFAULT NULL
                           ,p_visible_parameter4   IN kdlv_package_lines_int.VISIBLE_PARAMETER4%TYPE DEFAULT NULL
                           ,p_parameter5           IN kdlv_package_lines_int.PARAMETER5%TYPE DEFAULT NULL
                           ,p_visible_parameter5   IN kdlv_package_lines_int.VISIBLE_PARAMETER5%TYPE DEFAULT NULL
                           ,p_parameter6           IN kdlv_package_lines_int.PARAMETER6%TYPE DEFAULT NULL
                           ,p_visible_parameter6   IN kdlv_package_lines_int.VISIBLE_PARAMETER6%TYPE DEFAULT NULL
                           ,p_parameter7           IN kdlv_package_lines_int.PARAMETER7%TYPE DEFAULT NULL
                           ,p_visible_parameter7   IN kdlv_package_lines_int.VISIBLE_PARAMETER7%TYPE DEFAULT NULL
                           ,p_parameter8           IN kdlv_package_lines_int.PARAMETER8%TYPE DEFAULT NULL
                           ,p_visible_parameter8   IN kdlv_package_lines_int.VISIBLE_PARAMETER8%TYPE DEFAULT NULL
                           ,p_parameter9           IN kdlv_package_lines_int.PARAMETER9%TYPE DEFAULT NULL
                           ,p_visible_parameter9   IN kdlv_package_lines_int.VISIBLE_PARAMETER9%TYPE DEFAULT NULL
                           ,p_parameter10          IN kdlv_package_lines_int.PARAMETER10%TYPE DEFAULT NULL
                           ,p_visible_parameter10  IN kdlv_package_lines_int.VISIBLE_PARAMETER10%TYPE DEFAULT NULL
                           ,p_parameter11          IN kdlv_package_lines_int.PARAMETER11%TYPE DEFAULT NULL
                           ,p_visible_parameter11  IN kdlv_package_lines_int.VISIBLE_PARAMETER11%TYPE DEFAULT NULL
                           ,p_parameter12          IN kdlv_package_lines_int.PARAMETER12%TYPE DEFAULT NULL
                           ,p_visible_parameter12  IN kdlv_package_lines_int.VISIBLE_PARAMETER12%TYPE DEFAULT NULL
                           ,p_parameter13          IN kdlv_package_lines_int.PARAMETER13%TYPE DEFAULT NULL
                           ,p_visible_parameter13  IN kdlv_package_lines_int.VISIBLE_PARAMETER13%TYPE DEFAULT NULL
                           ,p_parameter14          IN kdlv_package_lines_int.PARAMETER14%TYPE DEFAULT NULL
                           ,p_visible_parameter14  IN kdlv_package_lines_int.VISIBLE_PARAMETER14%TYPE DEFAULT NULL
                           ,p_parameter15          IN kdlv_package_lines_int.PARAMETER15%TYPE DEFAULT NULL
                           ,p_visible_parameter15  IN kdlv_package_lines_int.VISIBLE_PARAMETER15%TYPE DEFAULT NULL
                           ,p_parameter16          IN kdlv_package_lines_int.PARAMETER16%TYPE DEFAULT NULL
                           ,p_visible_parameter16  IN kdlv_package_lines_int.VISIBLE_PARAMETER16%TYPE DEFAULT NULL
                           ,p_parameter17          IN kdlv_package_lines_int.PARAMETER17%TYPE DEFAULT NULL
                           ,p_visible_parameter17  IN kdlv_package_lines_int.VISIBLE_PARAMETER17%TYPE DEFAULT NULL
                           ,p_parameter18          IN kdlv_package_lines_int.PARAMETER18%TYPE DEFAULT NULL
                           ,p_visible_parameter18  IN kdlv_package_lines_int.VISIBLE_PARAMETER18%TYPE DEFAULT NULL
                           ,p_parameter19          IN kdlv_package_lines_int.PARAMETER19%TYPE DEFAULT NULL
                           ,p_visible_parameter19  IN kdlv_package_lines_int.VISIBLE_PARAMETER19%TYPE DEFAULT NULL
                           ,p_parameter20          IN kdlv_package_lines_int.PARAMETER20%TYPE DEFAULT NULL
                           ,p_visible_parameter20  IN kdlv_package_lines_int.VISIBLE_PARAMETER20%TYPE DEFAULT NULL
                           ,p_parameter21          IN kdlv_package_lines_int.PARAMETER21%TYPE DEFAULT NULL
                           ,p_visible_parameter21  IN kdlv_package_lines_int.VISIBLE_PARAMETER21%TYPE DEFAULT NULL
                           ,p_parameter22          IN kdlv_package_lines_int.PARAMETER22%TYPE DEFAULT NULL
                           ,p_visible_parameter22  IN kdlv_package_lines_int.VISIBLE_PARAMETER22%TYPE DEFAULT NULL
                           ,p_parameter23          IN kdlv_package_lines_int.PARAMETER23%TYPE DEFAULT NULL
                           ,p_visible_parameter23  IN kdlv_package_lines_int.VISIBLE_PARAMETER23%TYPE DEFAULT NULL
                           ,p_parameter24          IN kdlv_package_lines_int.PARAMETER24%TYPE DEFAULT NULL
                           ,p_visible_parameter24  IN kdlv_package_lines_int.VISIBLE_PARAMETER24%TYPE DEFAULT NULL
                           ,p_parameter25          IN kdlv_package_lines_int.PARAMETER25%TYPE DEFAULT NULL
                           ,p_visible_parameter25  IN kdlv_package_lines_int.VISIBLE_PARAMETER25%TYPE DEFAULT NULL
                           ,p_parameter26          IN kdlv_package_lines_int.PARAMETER26%TYPE DEFAULT NULL
                           ,p_visible_parameter26  IN kdlv_package_lines_int.VISIBLE_PARAMETER26%TYPE DEFAULT NULL
                           ,p_parameter27          IN kdlv_package_lines_int.PARAMETER27%TYPE DEFAULT NULL
                           ,p_visible_parameter27  IN kdlv_package_lines_int.VISIBLE_PARAMETER27%TYPE DEFAULT NULL
                           ,p_parameter28          IN kdlv_package_lines_int.PARAMETER28%TYPE DEFAULT NULL
                           ,p_visible_parameter28  IN kdlv_package_lines_int.VISIBLE_PARAMETER28%TYPE DEFAULT NULL
                           ,p_parameter29          IN kdlv_package_lines_int.PARAMETER29%TYPE DEFAULT NULL
                           ,p_visible_parameter29  IN kdlv_package_lines_int.VISIBLE_PARAMETER29%TYPE DEFAULT NULL
                           ,p_parameter30          IN kdlv_package_lines_int.PARAMETER30%TYPE DEFAULT NULL
                           ,p_visible_parameter30  IN kdlv_package_lines_int.VISIBLE_PARAMETER30%TYPE DEFAULT NULL
                           ,p_user_data1           IN kdlv_package_lines_int.user_data1%TYPE DEFAULT NULL
                           ,p_visible_user_data1   IN kdlv_package_lines_int.visible_user_data1%TYPE DEFAULT NULL
                           ,p_user_data2           IN kdlv_package_lines_int.user_data2%TYPE DEFAULT NULL
                           ,p_visible_user_data2   IN kdlv_package_lines_int.visible_user_data2%TYPE DEFAULT NULL
                           ,p_user_data3           IN kdlv_package_lines_int.user_data3%TYPE DEFAULT NULL
                           ,p_visible_user_data3   IN kdlv_package_lines_int.visible_user_data3%TYPE DEFAULT NULL
                           ,p_user_data4           IN kdlv_package_lines_int.user_data4%TYPE DEFAULT NULL
                           ,p_visible_user_data4   IN kdlv_package_lines_int.visible_user_data4%TYPE DEFAULT NULL
                           ,p_user_data5           IN kdlv_package_lines_int.user_data5%TYPE DEFAULT NULL
                           ,p_visible_user_data5   IN kdlv_package_lines_int.visible_user_data5%TYPE DEFAULT NULL
                           ,p_user_data6           IN kdlv_package_lines_int.user_data6%TYPE DEFAULT NULL
                           ,p_visible_user_data6   IN kdlv_package_lines_int.visible_user_data6%TYPE DEFAULT NULL
                           ,p_user_data7           IN kdlv_package_lines_int.user_data7%TYPE DEFAULT NULL
                           ,p_visible_user_data7   IN kdlv_package_lines_int.visible_user_data7%TYPE DEFAULT NULL
                           ,p_user_data8           IN kdlv_package_lines_int.user_data8%TYPE DEFAULT NULL
                           ,p_visible_user_data8   IN kdlv_package_lines_int.visible_user_data8%TYPE DEFAULT NULL
                           ,p_user_data9           IN kdlv_package_lines_int.user_data9%TYPE DEFAULT NULL
                           ,p_visible_user_data9   IN kdlv_package_lines_int.visible_user_data9%TYPE DEFAULT NULL
                           ,p_user_data10          IN kdlv_package_lines_int.user_data10%TYPE DEFAULT NULL
                           ,p_visible_user_data10  IN kdlv_package_lines_int.visible_user_data10%TYPE DEFAULT NULL
                           ,p_user_data11          IN kdlv_package_lines_int.user_data11%TYPE DEFAULT NULL
                           ,p_visible_user_data11  IN kdlv_package_lines_int.visible_user_data11%TYPE DEFAULT NULL
                           ,p_user_data12          IN kdlv_package_lines_int.user_data12%TYPE DEFAULT NULL
                           ,p_visible_user_data12  IN kdlv_package_lines_int.visible_user_data12%TYPE DEFAULT NULL
                           ,p_user_data13          IN kdlv_package_lines_int.user_data13%TYPE DEFAULT NULL
                           ,p_visible_user_data13  IN kdlv_package_lines_int.visible_user_data13%TYPE DEFAULT NULL
                           ,p_user_data14          IN kdlv_package_lines_int.user_data14%TYPE DEFAULT NULL
                           ,p_visible_user_data14  IN kdlv_package_lines_int.visible_user_data14%TYPE DEFAULT NULL
                           ,p_user_data15          IN kdlv_package_lines_int.user_data15%TYPE DEFAULT NULL
                           ,p_visible_user_data15  IN kdlv_package_lines_int.visible_user_data15%TYPE DEFAULT NULL
                           ,p_user_data16          IN kdlv_package_lines_int.user_data16%TYPE DEFAULT NULL
                           ,p_visible_user_data16  IN kdlv_package_lines_int.visible_user_data16%TYPE DEFAULT NULL
                           ,p_user_data17          IN kdlv_package_lines_int.user_data17%TYPE DEFAULT NULL
                           ,p_visible_user_data17  IN kdlv_package_lines_int.visible_user_data17%TYPE DEFAULT NULL
                           ,p_user_data18          IN kdlv_package_lines_int.user_data18%TYPE DEFAULT NULL
                           ,p_visible_user_data18  IN kdlv_package_lines_int.visible_user_data18%TYPE DEFAULT NULL
                           ,p_user_data19          IN kdlv_package_lines_int.user_data19%TYPE DEFAULT NULL
                           ,p_visible_user_data19  IN kdlv_package_lines_int.visible_user_data19%TYPE DEFAULT NULL
                           ,p_user_data20          IN kdlv_package_lines_int.user_data20%TYPE DEFAULT NULL
                           ,p_visible_user_data20  IN kdlv_package_lines_int.visible_user_data20%TYPE DEFAULT NULL)
    RETURN VARCHAR2 IS
    l_seq NUMBER := 1;
  BEGIN
    -- Sequence Nr. f?r Package Line erh?hen
    g_sql_num := 110;
    SELECT max(seq)
      INTO l_seq
      FROM kdlv_package_lines_int
     WHERE group_id = p_group_id AND package_id = p_package_id;

    IF l_seq IS NULL THEN
      l_seq := 1;
    ELSE
      l_seq := l_seq + 1;
    END IF;

    g_sql_num := 120;
    INSERT INTO kdlv_package_lines_int
      (package_line_interface_id
      ,package_interface_id
      ,group_id
      ,package_id
      ,package_number
      ,process_phase
      ,process_status
      ,created_by_username
      ,creation_date
      ,source_code
      ,seq
      ,object_type_name
      ,object_name
      ,release_flag
      ,parameter1
      ,visible_parameter1
      ,parameter2
      ,visible_parameter2
      ,parameter3
      ,visible_parameter3
      ,parameter4
      ,visible_parameter4
      ,parameter5
      ,visible_parameter5
      ,parameter6
      ,visible_parameter6
      ,parameter7
      ,visible_parameter7
      ,parameter8
      ,visible_parameter8
      ,parameter9
      ,visible_parameter9
      ,parameter10
      ,visible_parameter10
      ,parameter11
      ,visible_parameter11
      ,parameter12
      ,visible_parameter12
      ,parameter13
      ,visible_parameter13
      ,parameter14
      ,visible_parameter14
      ,parameter15
      ,visible_parameter15
      ,parameter16
      ,visible_parameter16
      ,parameter17
      ,visible_parameter17
      ,parameter18
      ,visible_parameter18
      ,parameter19
      ,visible_parameter19
      ,parameter20
      ,visible_parameter20
      ,parameter21
      ,visible_parameter21
      ,parameter22
      ,visible_parameter22
      ,parameter23
      ,visible_parameter23
      ,parameter24
      ,visible_parameter24
      ,parameter25
      ,visible_parameter25
      ,parameter26
      ,visible_parameter26
      ,parameter27
      ,visible_parameter27
      ,parameter28
      ,visible_parameter28
      ,parameter29
      ,visible_parameter29
      ,parameter30
      ,visible_parameter30
      ,user_data1
      ,visible_user_data1
      ,user_data2
      ,visible_user_data2
      ,user_data3
      ,visible_user_data3
      ,user_data4
      ,visible_user_data4
      ,user_data5
      ,visible_user_data5
      ,user_data6
      ,visible_user_data6
      ,user_data7
      ,visible_user_data7
      ,user_data8
      ,visible_user_data8
      ,user_data9
      ,visible_user_data9
      ,user_data10
      ,visible_user_data10
      ,user_data11
      ,visible_user_data11
      ,user_data12
      ,visible_user_data12
      ,user_data13
      ,visible_user_data13
      ,user_data14
      ,visible_user_data14
      ,user_data15
      ,visible_user_data15
      ,user_data16
      ,visible_user_data16
      ,user_data17
      ,visible_user_data17
      ,user_data18
      ,visible_user_data18
      ,user_data19
      ,visible_user_data19
      ,user_data20
      ,visible_user_data20)
    VALUES
      (kdlv_interfaces_s.nextval
      ,p_package_interface_id
      ,p_group_id
      ,p_package_id
      ,p_package_id
      ,1
      ,1
      ,p_created_by_username
      ,p_creation_date
      ,p_source_code
      ,l_seq
      ,p_object_type_name
      ,p_object_name
      ,p_release_flag
      ,p_parameter1
      ,p_visible_parameter1
      ,p_parameter2
      ,p_visible_parameter2
      ,p_parameter3
      ,p_visible_parameter3
      ,p_parameter4
      ,p_visible_parameter4
      ,p_parameter5
      ,p_visible_parameter5
      ,p_parameter6
      ,p_visible_parameter6
      ,p_parameter7
      ,p_visible_parameter7
      ,p_parameter8
      ,p_visible_parameter8
      ,p_parameter9
      ,p_visible_parameter9
      ,p_parameter10
      ,p_visible_parameter10
      ,p_parameter11
      ,p_visible_parameter11
      ,p_parameter12
      ,p_visible_parameter12
      ,p_parameter13
      ,p_visible_parameter13
      ,p_parameter14
      ,p_visible_parameter14
      ,p_parameter15
      ,p_visible_parameter15
      ,p_parameter16
      ,p_visible_parameter16
      ,p_parameter17
      ,p_visible_parameter17
      ,p_parameter18
      ,p_visible_parameter18
      ,p_parameter19
      ,p_visible_parameter19
      ,p_parameter20
      ,p_visible_parameter20
      ,p_parameter21
      ,p_visible_parameter21
      ,p_parameter22
      ,p_visible_parameter22
      ,p_parameter23
      ,p_visible_parameter23
      ,p_parameter24
      ,p_visible_parameter24
      ,p_parameter25
      ,p_visible_parameter25
      ,p_parameter26
      ,p_visible_parameter26
      ,p_parameter27
      ,p_visible_parameter27
      ,p_parameter28
      ,p_visible_parameter28
      ,p_parameter29
      ,p_visible_parameter29
      ,p_parameter30
      ,p_visible_parameter30
      ,NVL(p_user_data1, p_visible_user_data1)
      ,NVL(p_visible_user_data1, p_user_data1)
      ,NVL(p_user_data2, p_visible_user_data2)
      ,NVL(p_visible_user_data2, p_user_data2)
      ,NVL(p_user_data3, p_visible_user_data3)
      ,NVL(p_visible_user_data3, p_user_data3)
      ,NVL(p_user_data4, p_visible_user_data4)
      ,NVL(p_visible_user_data4, p_user_data4)
      ,NVL(p_user_data5, p_visible_user_data5)
      ,NVL(p_visible_user_data5, p_user_data5)
      ,NVL(p_user_data6, p_visible_user_data6)
      ,NVL(p_visible_user_data6, p_user_data6)
      ,NVL(p_user_data7, p_visible_user_data7)
      ,NVL(p_visible_user_data7, p_user_data7)
      ,NVL(p_user_data8, p_visible_user_data8)
      ,NVL(p_visible_user_data8, p_user_data8)
      ,NVL(p_user_data9, p_visible_user_data9)
      ,NVL(p_visible_user_data9, p_user_data9)
      ,NVL(p_user_data10, p_visible_user_data10)
      ,NVL(p_visible_user_data10, p_user_data10)
      ,NVL(p_user_data11, p_visible_user_data11)
      ,NVL(p_visible_user_data11, p_user_data11)
      ,NVL(p_user_data12, p_visible_user_data12)
      ,NVL(p_visible_user_data12, p_user_data12)
      ,NVL(p_user_data13, p_visible_user_data13)
      ,NVL(p_visible_user_data13, p_user_data13)
      ,NVL(p_user_data14, p_visible_user_data14)
      ,NVL(p_visible_user_data14, p_user_data14)
      ,NVL(p_user_data15, p_visible_user_data15)
      ,NVL(p_visible_user_data15, p_user_data15)
      ,NVL(p_user_data16, p_visible_user_data16)
      ,NVL(p_visible_user_data16, p_user_data16)
      ,NVL(p_user_data17, p_visible_user_data17)
      ,NVL(p_visible_user_data17, p_user_data17)
      ,NVL(p_user_data18, p_visible_user_data18)
      ,NVL(p_visible_user_data18, p_user_data18)
      ,NVL(p_user_data19, p_visible_user_data19)
      ,NVL(p_visible_user_data19, p_user_data19)
      ,NVL(p_user_data20, p_visible_user_data20)
      ,NVL(p_visible_user_data20, p_user_data20));

    RETURN g_success;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Exception in BETEO_kdlv_util.add_package');
      RETURN g_failure;
  END add_package_line;

  FUNCTION add_package_line_existing(p_group_id            IN kdlv_package_lines_int.group_id%TYPE
                                    ,p_package_id          IN kdlv_package_lines_int.package_id%TYPE
                                    ,p_created_by_username IN kdlv_package_lines_int.created_by_username%TYPE DEFAULT NULL
                                    ,p_creation_date       IN kdlv_package_lines_int.creation_date%TYPE DEFAULT NULL
                                    ,p_source_code         IN kdlv_package_lines_int.source_code%TYPE DEFAULT NULL
                                    ,p_object_type_name    IN kdlv_package_lines_int.object_type_name%TYPE
                                    ,p_object_name         IN kdlv_package_lines_int.object_name%TYPE
                                    ,p_release_flag        IN kdlv_package_lines_int.release_flag%TYPE DEFAULT 'Y'
                                    ,p_parameter1          IN kdlv_package_lines_int.PARAMETER1%TYPE DEFAULT NULL
                                    ,p_visible_parameter1  IN kdlv_package_lines_int.VISIBLE_PARAMETER1%TYPE DEFAULT NULL
                                    ,p_parameter2          IN kdlv_package_lines_int.PARAMETER2%TYPE DEFAULT NULL
                                    ,p_visible_parameter2  IN kdlv_package_lines_int.VISIBLE_PARAMETER2%TYPE DEFAULT NULL
                                    ,p_parameter3          IN kdlv_package_lines_int.PARAMETER3%TYPE DEFAULT NULL
                                    ,p_visible_parameter3  IN kdlv_package_lines_int.VISIBLE_PARAMETER3%TYPE DEFAULT NULL
                                    ,p_parameter4          IN kdlv_package_lines_int.PARAMETER4%TYPE DEFAULT NULL
                                    ,p_visible_parameter4  IN kdlv_package_lines_int.VISIBLE_PARAMETER4%TYPE DEFAULT NULL
                                    ,p_parameter5          IN kdlv_package_lines_int.PARAMETER5%TYPE DEFAULT NULL
                                    ,p_visible_parameter5  IN kdlv_package_lines_int.VISIBLE_PARAMETER5%TYPE DEFAULT NULL
                                    ,p_parameter6          IN kdlv_package_lines_int.PARAMETER6%TYPE DEFAULT NULL
                                    ,p_visible_parameter6  IN kdlv_package_lines_int.VISIBLE_PARAMETER6%TYPE DEFAULT NULL
                                    ,p_parameter7          IN kdlv_package_lines_int.PARAMETER7%TYPE DEFAULT NULL
                                    ,p_visible_parameter7  IN kdlv_package_lines_int.VISIBLE_PARAMETER7%TYPE DEFAULT NULL
                                    ,p_parameter8          IN kdlv_package_lines_int.PARAMETER8%TYPE DEFAULT NULL
                                    ,p_visible_parameter8  IN kdlv_package_lines_int.VISIBLE_PARAMETER8%TYPE DEFAULT NULL
                                    ,p_parameter9          IN kdlv_package_lines_int.PARAMETER9%TYPE DEFAULT NULL
                                    ,p_visible_parameter9  IN kdlv_package_lines_int.VISIBLE_PARAMETER9%TYPE DEFAULT NULL
                                    ,p_parameter10         IN kdlv_package_lines_int.PARAMETER10%TYPE DEFAULT NULL
                                    ,p_visible_parameter10 IN kdlv_package_lines_int.VISIBLE_PARAMETER10%TYPE DEFAULT NULL
                                    ,p_parameter11         IN kdlv_package_lines_int.PARAMETER11%TYPE DEFAULT NULL
                                    ,p_visible_parameter11 IN kdlv_package_lines_int.VISIBLE_PARAMETER11%TYPE DEFAULT NULL
                                    ,p_parameter12         IN kdlv_package_lines_int.PARAMETER12%TYPE DEFAULT NULL
                                    ,p_visible_parameter12 IN kdlv_package_lines_int.VISIBLE_PARAMETER12%TYPE DEFAULT NULL
                                    ,p_parameter13         IN kdlv_package_lines_int.PARAMETER13%TYPE DEFAULT NULL
                                    ,p_visible_parameter13 IN kdlv_package_lines_int.VISIBLE_PARAMETER13%TYPE DEFAULT NULL
                                    ,p_parameter14         IN kdlv_package_lines_int.PARAMETER14%TYPE DEFAULT NULL
                                    ,p_visible_parameter14 IN kdlv_package_lines_int.VISIBLE_PARAMETER14%TYPE DEFAULT NULL
                                    ,p_parameter15         IN kdlv_package_lines_int.PARAMETER15%TYPE DEFAULT NULL
                                    ,p_visible_parameter15 IN kdlv_package_lines_int.VISIBLE_PARAMETER15%TYPE DEFAULT NULL
                                    ,p_parameter16         IN kdlv_package_lines_int.PARAMETER16%TYPE DEFAULT NULL
                                    ,p_visible_parameter16 IN kdlv_package_lines_int.VISIBLE_PARAMETER16%TYPE DEFAULT NULL
                                    ,p_parameter17         IN kdlv_package_lines_int.PARAMETER17%TYPE DEFAULT NULL
                                    ,p_visible_parameter17 IN kdlv_package_lines_int.VISIBLE_PARAMETER17%TYPE DEFAULT NULL
                                    ,p_parameter18         IN kdlv_package_lines_int.PARAMETER18%TYPE DEFAULT NULL
                                    ,p_visible_parameter18 IN kdlv_package_lines_int.VISIBLE_PARAMETER18%TYPE DEFAULT NULL
                                    ,p_parameter19         IN kdlv_package_lines_int.PARAMETER19%TYPE DEFAULT NULL
                                    ,p_visible_parameter19 IN kdlv_package_lines_int.VISIBLE_PARAMETER19%TYPE DEFAULT NULL
                                    ,p_parameter20         IN kdlv_package_lines_int.PARAMETER20%TYPE DEFAULT NULL
                                    ,p_visible_parameter20 IN kdlv_package_lines_int.VISIBLE_PARAMETER20%TYPE DEFAULT NULL
                                    ,p_parameter21         IN kdlv_package_lines_int.PARAMETER21%TYPE DEFAULT NULL
                                    ,p_visible_parameter21 IN kdlv_package_lines_int.VISIBLE_PARAMETER21%TYPE DEFAULT NULL
                                    ,p_parameter22         IN kdlv_package_lines_int.PARAMETER22%TYPE DEFAULT NULL
                                    ,p_visible_parameter22 IN kdlv_package_lines_int.VISIBLE_PARAMETER22%TYPE DEFAULT NULL
                                    ,p_parameter23         IN kdlv_package_lines_int.PARAMETER23%TYPE DEFAULT NULL
                                    ,p_visible_parameter23 IN kdlv_package_lines_int.VISIBLE_PARAMETER23%TYPE DEFAULT NULL
                                    ,p_parameter24         IN kdlv_package_lines_int.PARAMETER24%TYPE DEFAULT NULL
                                    ,p_visible_parameter24 IN kdlv_package_lines_int.VISIBLE_PARAMETER24%TYPE DEFAULT NULL
                                    ,p_parameter25         IN kdlv_package_lines_int.PARAMETER25%TYPE DEFAULT NULL
                                    ,p_visible_parameter25 IN kdlv_package_lines_int.VISIBLE_PARAMETER25%TYPE DEFAULT NULL
                                    ,p_parameter26         IN kdlv_package_lines_int.PARAMETER26%TYPE DEFAULT NULL
                                    ,p_visible_parameter26 IN kdlv_package_lines_int.VISIBLE_PARAMETER26%TYPE DEFAULT NULL
                                    ,p_parameter27         IN kdlv_package_lines_int.PARAMETER27%TYPE DEFAULT NULL
                                    ,p_visible_parameter27 IN kdlv_package_lines_int.VISIBLE_PARAMETER27%TYPE DEFAULT NULL
                                    ,p_parameter28         IN kdlv_package_lines_int.PARAMETER28%TYPE DEFAULT NULL
                                    ,p_visible_parameter28 IN kdlv_package_lines_int.VISIBLE_PARAMETER28%TYPE DEFAULT NULL
                                    ,p_parameter29         IN kdlv_package_lines_int.PARAMETER29%TYPE DEFAULT NULL
                                    ,p_visible_parameter29 IN kdlv_package_lines_int.VISIBLE_PARAMETER29%TYPE DEFAULT NULL
                                    ,p_parameter30         IN kdlv_package_lines_int.PARAMETER30%TYPE DEFAULT NULL
                                    ,p_visible_parameter30 IN kdlv_package_lines_int.VISIBLE_PARAMETER30%TYPE DEFAULT NULL
                                    ,p_user_data1          IN kdlv_package_lines_int.user_data1%TYPE DEFAULT NULL
                                    ,p_visible_user_data1  IN kdlv_package_lines_int.visible_user_data1%TYPE DEFAULT NULL
                                    ,p_user_data2          IN kdlv_package_lines_int.user_data2%TYPE DEFAULT NULL
                                    ,p_visible_user_data2  IN kdlv_package_lines_int.visible_user_data2%TYPE DEFAULT NULL
                                    ,p_user_data3          IN kdlv_package_lines_int.user_data3%TYPE DEFAULT NULL
                                    ,p_visible_user_data3  IN kdlv_package_lines_int.visible_user_data3%TYPE DEFAULT NULL
                                    ,p_user_data4          IN kdlv_package_lines_int.user_data4%TYPE DEFAULT NULL
                                    ,p_visible_user_data4  IN kdlv_package_lines_int.visible_user_data4%TYPE DEFAULT NULL
                                    ,p_user_data5          IN kdlv_package_lines_int.user_data5%TYPE DEFAULT NULL
                                    ,p_visible_user_data5  IN kdlv_package_lines_int.visible_user_data5%TYPE DEFAULT NULL
                                    ,p_user_data6          IN kdlv_package_lines_int.user_data6%TYPE DEFAULT NULL
                                    ,p_visible_user_data6  IN kdlv_package_lines_int.visible_user_data6%TYPE DEFAULT NULL
                                    ,p_user_data7          IN kdlv_package_lines_int.user_data7%TYPE DEFAULT NULL
                                    ,p_visible_user_data7  IN kdlv_package_lines_int.visible_user_data7%TYPE DEFAULT NULL
                                    ,p_user_data8          IN kdlv_package_lines_int.user_data8%TYPE DEFAULT NULL
                                    ,p_visible_user_data8  IN kdlv_package_lines_int.visible_user_data8%TYPE DEFAULT NULL
                                    ,p_user_data9          IN kdlv_package_lines_int.user_data9%TYPE DEFAULT NULL
                                    ,p_visible_user_data9  IN kdlv_package_lines_int.visible_user_data9%TYPE DEFAULT NULL
                                    ,p_user_data10         IN kdlv_package_lines_int.user_data10%TYPE DEFAULT NULL
                                    ,p_visible_user_data10 IN kdlv_package_lines_int.visible_user_data10%TYPE DEFAULT NULL
                                    ,p_user_data11         IN kdlv_package_lines_int.user_data11%TYPE DEFAULT NULL
                                    ,p_visible_user_data11 IN kdlv_package_lines_int.visible_user_data11%TYPE DEFAULT NULL
                                    ,p_user_data12         IN kdlv_package_lines_int.user_data12%TYPE DEFAULT NULL
                                    ,p_visible_user_data12 IN kdlv_package_lines_int.visible_user_data12%TYPE DEFAULT NULL
                                    ,p_user_data13         IN kdlv_package_lines_int.user_data13%TYPE DEFAULT NULL
                                    ,p_visible_user_data13 IN kdlv_package_lines_int.visible_user_data13%TYPE DEFAULT NULL
                                    ,p_user_data14         IN kdlv_package_lines_int.user_data14%TYPE DEFAULT NULL
                                    ,p_visible_user_data14 IN kdlv_package_lines_int.visible_user_data14%TYPE DEFAULT NULL
                                    ,p_user_data15         IN kdlv_package_lines_int.user_data15%TYPE DEFAULT NULL
                                    ,p_visible_user_data15 IN kdlv_package_lines_int.visible_user_data15%TYPE DEFAULT NULL
                                    ,p_user_data16         IN kdlv_package_lines_int.user_data16%TYPE DEFAULT NULL
                                    ,p_visible_user_data16 IN kdlv_package_lines_int.visible_user_data16%TYPE DEFAULT NULL
                                    ,p_user_data17         IN kdlv_package_lines_int.user_data17%TYPE DEFAULT NULL
                                    ,p_visible_user_data17 IN kdlv_package_lines_int.visible_user_data17%TYPE DEFAULT NULL
                                    ,p_user_data18         IN kdlv_package_lines_int.user_data18%TYPE DEFAULT NULL
                                    ,p_visible_user_data18 IN kdlv_package_lines_int.visible_user_data18%TYPE DEFAULT NULL
                                    ,p_user_data19         IN kdlv_package_lines_int.user_data19%TYPE DEFAULT NULL
                                    ,p_visible_user_data19 IN kdlv_package_lines_int.visible_user_data19%TYPE DEFAULT NULL
                                    ,p_user_data20         IN kdlv_package_lines_int.user_data20%TYPE DEFAULT NULL
                                    ,p_visible_user_data20 IN kdlv_package_lines_int.visible_user_data20%TYPE DEFAULT NULL
                                    ,p_app_code            IN kdlv_package_lines_int.app_code%TYPE DEFAULT NULL)
    RETURN VARCHAR2 IS
    l_seq               NUMBER := 1;
    l_max_existing_seq  NUMBER := 1;
    l_max_interface_seq NUMBER := 1;
    l_message_type      NUMBER;
    l_message_name      VARCHAR2(100);
    l_message           VARCHAR2(2000);
  BEGIN
    --------------------------------------------
    -- Derive Sequence Number in Package      --
    --------------------------------------------
    g_sql_num := 110;
    SELECT max(seq)
      INTO l_max_interface_seq
      FROM kdlv_package_lines_int
     WHERE group_id = p_group_id AND package_id = p_package_id;

    IF l_max_interface_seq IS NULL THEN
      l_max_interface_seq := 1;
    ELSE
      l_max_interface_seq := l_max_interface_seq + 1;
    END IF;

    g_sql_num := 115;
    SELECT max(seq)
      INTO l_max_existing_seq
      FROM kdlv_package_lines
     WHERE package_id = p_package_id;

    IF l_max_existing_seq IS NULL THEN
      l_seq := l_max_interface_seq;
    ELSE
      l_max_existing_seq := l_max_existing_seq + 1;
      IF (l_max_existing_seq > l_max_interface_seq) THEN
        l_seq := l_max_existing_seq;
      ELSE
        l_seq := l_max_interface_seq;
      END IF;
    END IF;

    --------------------------------------------
    -- Insert data into open interface table  --
    --------------------------------------------
    g_sql_num := 120;
    INSERT INTO kdlv_package_lines_int
      (package_line_interface_id
      ,group_id
      ,package_id
      ,package_number
      ,process_phase
      ,process_status
      ,created_by_username
      ,creation_date
      ,source_code
      ,seq
      ,object_type_name
      ,object_name
      ,release_flag
      ,parameter1
      ,visible_parameter1
      ,parameter2
      ,visible_parameter2
      ,parameter3
      ,visible_parameter3
      ,parameter4
      ,visible_parameter4
      ,parameter5
      ,visible_parameter5
      ,parameter6
      ,visible_parameter6
      ,parameter7
      ,visible_parameter7
      ,parameter8
      ,visible_parameter8
      ,parameter9
      ,visible_parameter9
      ,parameter10
      ,visible_parameter10
      ,parameter11
      ,visible_parameter11
      ,parameter12
      ,visible_parameter12
      ,parameter13
      ,visible_parameter13
      ,parameter14
      ,visible_parameter14
      ,parameter15
      ,visible_parameter15
      ,parameter16
      ,visible_parameter16
      ,parameter17
      ,visible_parameter17
      ,parameter18
      ,visible_parameter18
      ,parameter19
      ,visible_parameter19
      ,parameter20
      ,visible_parameter20
      ,parameter21
      ,visible_parameter21
      ,parameter22
      ,visible_parameter22
      ,parameter23
      ,visible_parameter23
      ,parameter24
      ,visible_parameter24
      ,parameter25
      ,visible_parameter25
      ,parameter26
      ,visible_parameter26
      ,parameter27
      ,visible_parameter27
      ,parameter28
      ,visible_parameter28
      ,parameter29
      ,visible_parameter29
      ,parameter30
      ,visible_parameter30
      ,user_data1
      ,visible_user_data1
      ,user_data2
      ,visible_user_data2
      ,user_data3
      ,visible_user_data3
      ,user_data4
      ,visible_user_data4
      ,user_data5
      ,visible_user_data5
      ,user_data6
      ,visible_user_data6
      ,user_data7
      ,visible_user_data7
      ,user_data8
      ,visible_user_data8
      ,user_data9
      ,visible_user_data9
      ,user_data10
      ,visible_user_data10
      ,user_data11
      ,visible_user_data11
      ,user_data12
      ,visible_user_data12
      ,user_data13
      ,visible_user_data13
      ,user_data14
      ,visible_user_data14
      ,user_data15
      ,visible_user_data15
      ,user_data16
      ,visible_user_data16
      ,user_data17
      ,visible_user_data17
      ,user_data18
      ,visible_user_data18
      ,user_data19
      ,visible_user_data19
      ,user_data20
      ,visible_user_data20
      ,app_code)
    VALUES
      (null --kdlv_interfaces_s.nextval
      ,p_group_id
      ,p_package_id
      ,p_package_id
      ,1
      ,1
      ,p_created_by_username
      ,p_creation_date
      ,p_source_code
      ,l_seq
      ,p_object_type_name
      ,p_object_name
      ,p_release_flag
      ,p_parameter1
      ,p_visible_parameter1
      ,p_parameter2
      ,p_visible_parameter2
      ,p_parameter3
      ,p_visible_parameter3
      ,p_parameter4
      ,p_visible_parameter4
      ,p_parameter5
      ,p_visible_parameter5
      ,p_parameter6
      ,p_visible_parameter6
      ,p_parameter7
      ,p_visible_parameter7
      ,p_parameter8
      ,p_visible_parameter8
      ,p_parameter9
      ,p_visible_parameter9
      ,p_parameter10
      ,p_visible_parameter10
      ,p_parameter11
      ,p_visible_parameter11
      ,p_parameter12
      ,p_visible_parameter12
      ,p_parameter13
      ,p_visible_parameter13
      ,p_parameter14
      ,p_visible_parameter14
      ,p_parameter15
      ,p_visible_parameter15
      ,p_parameter16
      ,p_visible_parameter16
      ,p_parameter17
      ,p_visible_parameter17
      ,p_parameter18
      ,p_visible_parameter18
      ,p_parameter19
      ,p_visible_parameter19
      ,p_parameter20
      ,p_visible_parameter20
      ,p_parameter21
      ,p_visible_parameter21
      ,p_parameter22
      ,p_visible_parameter22
      ,p_parameter23
      ,p_visible_parameter23
      ,p_parameter24
      ,p_visible_parameter24
      ,p_parameter25
      ,p_visible_parameter25
      ,p_parameter26
      ,p_visible_parameter26
      ,p_parameter27
      ,p_visible_parameter27
      ,p_parameter28
      ,p_visible_parameter28
      ,p_parameter29
      ,p_visible_parameter29
      ,p_parameter30
      ,p_visible_parameter30
      ,NVL(p_user_data1, p_visible_user_data1)
      ,NVL(p_visible_user_data1, p_user_data1)
      ,NVL(p_user_data2, p_visible_user_data2)
      ,NVL(p_visible_user_data2, p_user_data2)
      ,NVL(p_user_data3, p_visible_user_data3)
      ,NVL(p_visible_user_data3, p_user_data3)
      ,NVL(p_user_data4, p_visible_user_data4)
      ,NVL(p_visible_user_data4, p_user_data4)
      ,NVL(p_user_data5, p_visible_user_data5)
      ,NVL(p_visible_user_data5, p_user_data5)
      ,NVL(p_user_data6, p_visible_user_data6)
      ,NVL(p_visible_user_data6, p_user_data6)
      ,NVL(p_user_data7, p_visible_user_data7)
      ,NVL(p_visible_user_data7, p_user_data7)
      ,NVL(p_user_data8, p_visible_user_data8)
      ,NVL(p_visible_user_data8, p_user_data8)
      ,NVL(p_user_data9, p_visible_user_data9)
      ,NVL(p_visible_user_data9, p_user_data9)
      ,NVL(p_user_data10, p_visible_user_data10)
      ,NVL(p_visible_user_data10, p_user_data10)
      ,NVL(p_user_data11, p_visible_user_data11)
      ,NVL(p_visible_user_data11, p_user_data11)
      ,NVL(p_user_data12, p_visible_user_data12)
      ,NVL(p_visible_user_data12, p_user_data12)
      ,NVL(p_user_data13, p_visible_user_data13)
      ,NVL(p_visible_user_data13, p_user_data13)
      ,NVL(p_user_data14, p_visible_user_data14)
      ,NVL(p_visible_user_data14, p_user_data14)
      ,NVL(p_user_data15, p_visible_user_data15)
      ,NVL(p_visible_user_data15, p_user_data15)
      ,NVL(p_user_data16, p_visible_user_data16)
      ,NVL(p_visible_user_data16, p_user_data16)
      ,NVL(p_user_data17, p_visible_user_data17)
      ,NVL(p_visible_user_data17, p_user_data17)
      ,NVL(p_user_data18, p_visible_user_data18)
      ,NVL(p_visible_user_data18, p_user_data18)
      ,NVL(p_user_data19, p_visible_user_data19)
      ,NVL(p_visible_user_data19, p_user_data19)
      ,NVL(p_user_data20, p_visible_user_data20)
      ,NVL(p_visible_user_data20, p_user_data20)
      ,p_app_code);

    RETURN g_success;

  EXCEPTION
    WHEN OTHERS THEN
      knta_message.get_ora(g_package_name
                          ,g_sql_num
                          ,l_message_type
                          ,l_message_name
                          ,l_message);
      dbms_output.put_line('  MESSAGE_TYPE: ' || l_message_type);
      dbms_output.put_line('  MESSAGE_NAME: ' || l_message_name);
      dbms_output.put_line('  MESSAGE     : ' || l_message);
      RETURN g_failure;
  END add_package_line_existing;

  FUNCTION run_package_interface(p_group_id IN NUMBER
                                ,p_username IN VARCHAR2) RETURN VARCHAR2 IS
    l_group_id     NUMBER;
    l_user_id      NUMBER;
    l_message_type NUMBER;
    l_message_name VARCHAR2(100);
    l_message      VARCHAR2(4000);
    l_err_count    NUMBER := 0;

    l_errors   c_get_errors%ROWTYPE;
    l_warnings c_get_warnings%ROWTYPE;

  BEGIN
    l_group_id := p_group_id;

    -- User ID ermitteln
    g_sql_num := 210;
    SELECT u.user_id
      INTO l_user_id
      FROM knta_users u
     WHERE u.username = p_username;

    IF l_user_id IS NULL THEN
      g_sql_msg := 'ITG User "' || p_username || '" does not exist.';
      RAISE APPLICATION_ERROR;
    END IF;

    g_sql_num := 220;

    kdlv_package_int.run_interface(p_group_id     => l_group_id
                                  ,p_user_id      => l_user_id
                                  ,o_message_type => l_message_type
                                  ,o_message_name => l_message_name
                                  ,o_message      => l_message);

    dbms_output.put_line('run_interface: type="' || l_message_type ||
                         '" name="' || l_message_name || '"');
    dbms_output.put_line('run_interface: message="' || l_message || '"');

    -- Interface Fehler und Warnungen ausgeben
    OPEN c_get_errors(l_group_id);
    FETCH c_get_errors
      INTO l_errors;
    WHILE c_get_errors%FOUND LOOP
      l_err_count := l_err_count + 1;
      dbms_output.put_line('ERROR: ' || l_errors.message_name);
      dbms_output.put_line('ERROR: ' || l_errors.message);
      FETCH c_get_errors
        INTO l_errors;
    END LOOP;
    CLOSE c_get_errors;

    OPEN c_get_warnings(l_group_id);
    FETCH c_get_warnings
      INTO l_warnings;
    WHILE c_get_warnings%FOUND LOOP
      dbms_output.put_line('WARNING: ' || l_warnings.message_name);
      dbms_output.put_line('WARNING: ' || l_warnings.message);
      FETCH c_get_warnings
        INTO l_warnings;
    END LOOP;
    CLOSE c_get_warnings;

    IF l_err_count > 0 THEN
      RETURN g_failure;
    ELSE
      RETURN g_success;
    END IF;

  EXCEPTION
    WHEN APPLICATION_ERROR THEN
      dbms_output.put_line('ERROR: ' || g_sql_msg || ' (Statement ' ||
                           g_sql_num || ')');
      RETURN g_failure;
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR: SQL Exception (Statement ' || g_sql_num || ')');
      RETURN g_failure;
  END run_package_interface;

  FUNCTION create_ref_request_package(p_parent_request_id IN kcrt_requests.request_id%TYPE
                                     ,p_child_package_id  IN kdlv_packages.package_id%TYPE)
    RETURN VARCHAR2 IS

    l_creation_date    DATE;
    l_last_update_date DATE;
    l_message_type     NUMBER;
    l_message_name     VARCHAR2(100);
    l_message          VARCHAR2(2000);

    l_reference_id NUMBER;

  BEGIN
    l_reference_id := NULL;

    g_sql_num := 310;
    KNTA_REFERENCES_TH.PROCESS_ROW(p_event                    => 'INSERT'
                                  ,p_reference_id             => l_reference_id
                                  ,p_last_updated_by          => 1
                                  ,p_target_type_code         => KNTA_CONSTANT.ENTITY_PACKAGE
                                  ,p_ref_relationship_id      => KNTA_CONSTANT.REF_REQUEST_IS_PARENT_OF_PKG
                                  ,p_source_entity_id         => KNTA_CONSTANT.ENTITY_REQUEST
                                  ,p_source_id                => p_parent_request_id
                                  ,p_original_source_id       => p_parent_request_id
                                  ,p_reverse_reference_id     => NULL
                                  ,p_enabled_flag             => 'Y'
                                  ,p_parameter_set_context_ID => 610
                                  ,p_parameter1               => p_child_package_id
                                  ,p_visible_parameter1       => p_child_package_id
                                  ,p_usr_dbg                  => NULL
                                  ,O_LAST_UPDATE_DATE         => l_last_update_date
                                  ,O_CREATION_DATE            => l_creation_date
                                  ,O_MESSAGE_TYPE             => l_message_type
                                  ,O_MESSAGE_NAME             => l_message_name
                                  ,O_MESSAGE                  => l_message);

    COMMIT;
    dbms_output.put_line('  MESSAGE_TYPE: ' || l_message_type);
    dbms_output.put_line('  MESSAGE_NAME: ' || l_message_name);
    dbms_output.put_line('  MESSAGE     : ' || l_message);
    return g_success;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR: KNTA_REFERENCES_TH.PROCESS_ROW()');
      dbms_output.put_line('ERROR: SQL Exception (Statement ' || g_sql_num || ')');
      dbms_output.put_line('  MESSAGE_TYPE: ' || l_message_type);
      dbms_output.put_line('  MESSAGE_NAME: ' || l_message_name);
      dbms_output.put_line('  MESSAGE     : ' || l_message);
      RETURN g_failure;

  END create_ref_request_package;

  /*
  * Function submit_Package() starts the workflow for the package with the package ID given
  * in parameter p_package_id.
  *
  * Returns:
  *   'SUCCESS' if package was successfully submitted
  *   'FAILURE' otherwise
  */
  FUNCTION submit_package(p_package_id IN kdlv_packages.package_id%TYPE
                         ,p_username   IN kwfl_transactions_int.created_username%TYPE)
    RETURN VARCHAR2 IS
    l_group_id NUMBER := 0;

    l_message_type NUMBER;
    l_message_name VARCHAR2(80);
    l_message      VARCHAR2(1000);

    l_result VARCHAR2(10) := g_success;
  BEGIN
    -- Get group id from sequence
    SELECT knta_interface_groups_s.nextval INTO l_group_id FROM sys.dual;

    -- Insert row into transaction open interface table
    kwfl_txn_int.insert_row(p_event                 => 'INSTANCE_SET_CREATE'
                           ,p_group_id              => l_group_id
                           ,p_created_username      => p_username
                           ,p_source                => 'BETEO_kdlv_util.submit_package'
                           ,p_request_number        => NULL
                           ,p_package_number        => p_package_id
                           ,p_package_line_seq      => NULL
                           ,p_workflow_step_name    => NULL
                           ,p_workflow_step_seq     => NULL
                           ,p_visible_result_value  => NULL
                           ,p_user_comments         => NULL
                           ,p_delegated_to_username => NULL
                           ,p_schedule_date         => NULL
                           ,p_to_workflow_step_name => NULL
                           ,p_to_workflow_step_seq  => NULL
                           ,o_message_type          => l_message_type
                           ,o_message_name          => l_message_name
                           ,o_message               => l_message);
    if (l_message_type != KNTA_Constant.SUCCESS) then
      dbms_output.put_line('ERROR: KWFL_TXN_INT.INSERT_ROW()');
      dbms_output.put_line('  MESSAGE_TYPE: ' || l_message_type);
      dbms_output.put_line('  MESSAGE_NAME: ' || l_message_name);
      dbms_output.put_line('  MESSAGE     : ' || l_message);
      l_result := g_failure;
    else
      -- Row in open interface table successfully created,
      -- now running interface
      kwfl_txn_int.run_interface(p_group_id      => l_group_id
                                ,p_source        => 'BETEO_kdlv_util.submit_package'
                                ,p_user_id       => p_username
                                ,p_resubmit_flag => 'N'
                                ,o_message_type  => l_message_type
                                ,o_message_name  => l_message_name
                                ,o_message       => l_message);
      if (l_message_type != KNTA_Constant.SUCCESS) then
        dbms_output.put_line('ERROR: KWFL_TXN_INT.RUN_INTERFACE()');
        dbms_output.put_line('  MESSAGE_TYPE: ' || l_message_type);
        dbms_output.put_line('  MESSAGE_NAME: ' || l_message_name);
        dbms_output.put_line('  MESSAGE     : ' || l_message);
        l_result := g_failure;
      end if;
    end if;

    return l_result;
  END submit_package;

  FUNCTION create_pkg_from_req(p_source_request_id      IN kcrt_requests.request_id%TYPE
                              ,p_source_wf_step_id      IN kwfl_workflow_steps.workflow_step_id%TYPE
                              ,p_created_by_username    IN knta_users.username%TYPE
                              ,p_workflow_name          IN kwfl_workflows.workflow_name%TYPE
                              ,p_description            IN kdlv_packages.description%TYPE
                              ,p_priority_code          IN kdlv_packages.priority_code%TYPE DEFAULT 'NORMAL'
                              ,p_priority_seq           IN kdlv_packages.priority_seq%TYPE DEFAULT 50
                              ,p_assigned_to_username   IN knta_users.username%TYPE DEFAULT NULL
                              ,p_assigned_to_group_name IN knta_security_groups.security_group_name%TYPE DEFAULT NULL
                              ,p_package_type           IN kdlv_packages.package_type_code%TYPE DEFAULT NULL
                              ,p_package_group          IN kdlv_packages.project_code%TYPE DEFAULT NULL
                              ,o_package_id             OUT kdlv_packages.package_id%TYPE
                              ,o_message                OUT VARCHAR2)
    RETURN VARCHAR2 IS
    l_priority_meaning      knta_lookups.meaning%TYPE;
    l_package_type_meaning  knta_lookups.meaning%TYPE;
    l_package_group_meaning knta_lookups.meaning%TYPE;
    l_created_by_user_id    knta_users.user_id%TYPE;
    l_assigned_to_user_id   knta_users.user_id%TYPE;
    l_assigned_to_group_id  knta_security_groups.security_group_id%TYPE;
    l_workflow_id           kwfl_workflows.workflow_id%TYPE;
    l_group_id              kdlv_packages_int.group_id%TYPE;
    l_package_interface_id  kdlv_packages_int.package_interface_id%TYPE;
    l_step_transaction_id   kwfl_step_transactions.step_transaction_id%TYPE;
    l_result                VARCHAR2(30);
  BEGIN
    -- Check parameters
    l_step_transaction_id := get_active_step_transaction_id(p_source_request_id
                                                           ,p_source_wf_step_id);
    if (l_step_transaction_id = -1) then
      o_message := 'Cannot retrieve unique step transaction id.';
      return g_failure;
    end if;

    l_workflow_id := get_workflow_id(p_workflow_name);
    if (l_workflow_id = -1) then
      o_message := 'Cannot retrieve workflow id for workflow "' ||
                   p_workflow_name || '".';
      return g_failure;
    end if;

    l_created_by_user_id := get_user_id(p_created_by_username);
    if (l_created_by_user_id = -1) then
      o_message := 'Cannot retrieve user id for creator "' ||
                   p_created_by_username || '".';
      return g_failure;
    end if;

    l_assigned_to_user_id := NULL;
    if (p_assigned_to_username is not NULL) then
      l_assigned_to_user_id := get_user_id(p_assigned_to_username);
      if (l_assigned_to_user_id = -1) then
        o_message := 'Cannot retrieve user id for assigned to user "' ||
                     p_assigned_to_username || '".';
        return g_failure;
      end if;
    end if;

    l_assigned_to_group_id := NULL;
    if (p_assigned_to_group_name is not NULL) then
      l_assigned_to_group_id := get_security_group_id(p_assigned_to_group_name);
      if (l_assigned_to_group_id = -1) then
        o_message := 'Cannot retrieve security group id for security group "' ||
                     p_assigned_to_group_name || '".';
        return g_failure;
      end if;
    end if;

    l_priority_meaning := NULL;
    if (p_priority_code is not NULL) then
      l_priority_meaning := get_validation_meaning('DLV - Package Priority - Enabled'
                                                  ,p_priority_code
                                                  ,o_message);
      if (l_priority_meaning = '***ERROR***') then
        o_message := 'p_priority_code ' || o_message;
        return g_failure;
      end if;
    end if;

    l_package_type_meaning := NULL;
    if (p_package_type is not NULL) then
      l_package_type_meaning := get_validation_meaning('DLV - Package Type - Enabled'
                                                      ,p_package_type
                                                      ,o_message);
      if (l_package_type_meaning = '***ERROR***') then
        o_message := 'p_package_type ' || o_message;
        return g_failure;
      end if;
    end if;

    l_package_group_meaning := NULL;
    if (p_package_group is not NULL) then
      l_package_group_meaning := get_validation_meaning('KNTA - Package and Request Groups'
                                                       ,p_package_group
                                                       ,o_message);
      if (l_package_group_meaning = '***ERROR***') then
        o_message := 'p_package_group ' || o_message;
        return g_failure;
      end if;
    end if;

    -- Add Package data to open interface table
    l_result := add_package(p_package_interface_id   => l_package_interface_id
                           ,p_group_id               => l_group_id
                           ,p_created_by_username    => p_created_by_username
                           ,p_creation_date          => SYSDATE
                           ,p_source_code            => 'BETEO_KDLV_UTIL'
                           ,p_package_id             => o_package_id
                           ,p_requested_by_username  => p_created_by_username
                           ,p_assigned_to_username   => p_assigned_to_username
                           ,p_assigned_to_group_name => p_assigned_to_group_name
                           ,p_description            => p_description
                           ,p_workflow_name          => p_workflow_name
                           ,p_release_flag           => 'N'
                           ,p_package_group_code     => p_package_group
                           ,p_package_type_code      => p_package_type
                           ,p_priority_code          => p_priority_code);
    if (l_result = g_failure) then
      o_message := 'Cannot add package to open interface table. Call to add_package() failed.';
      return g_failure;
    end if;

    -- Create package (run open interface)
    l_result := run_package_interface(p_group_id => l_group_id
                                     ,p_username => p_created_by_username);
    if (l_result = g_failure) then
      o_message := 'Cannot create package. Call to run_package_interface() failed.';
      return g_failure;
    end if;

    -- Create reference between request and package
    l_result := create_ref_request_package(p_source_request_id
                                          ,o_package_id);
    if (l_result = g_failure) then
      o_message := 'Cannot create reference between package #' ||
                   o_package_id || 'and request #' || p_source_request_id ||
                   '. Call to create_ref_request_package() failed.';
      return g_failure;
    end if;

    -- Adjust step transaction data
    UPDATE kwfl_step_transactions wst
       SET (wst.last_update_date, wst.last_updated_by, wst.child_package_id, wst.parameter_set_context_id, wst.parameter1, wst.visible_parameter1, wst.parameter2, wst.visible_parameter2, wst.parameter3, wst.visible_parameter3, wst.parameter4, wst.visible_parameter4, wst.parameter5, wst.visible_parameter5, wst.parameter6, wst.visible_parameter6, wst.parameter7, wst.visible_parameter7, wst.parameter8, wst.visible_parameter8, wst.parameter9, wst.visible_parameter9, wst.parameter10, wst.visible_parameter10, wst.parameter11, wst.visible_parameter11, wst.parameter12, wst.visible_parameter12, wst.parameter13, wst.visible_parameter13, wst.parameter14, wst.visible_parameter14) = (SELECT SYSDATE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,l_created_by_user_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,o_package_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,7
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,o_package_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,o_package_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_description
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_description
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,l_workflow_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_workflow_name
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,l_assigned_to_user_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_assigned_to_username
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,l_assigned_to_group_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_assigned_to_group_name
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_package_type
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,l_package_type_meaning
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_priority_code
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,l_priority_meaning
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_package_group
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,l_package_group_meaning
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_priority_seq
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_priority_seq
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,'NEW'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,'New'
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,o_package_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,o_package_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_created_by_username
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_created_by_username
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,to_char(SYSDATE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ,'YYYY-MM-DD HH24:MI:SS')
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,to_char(SYSDATE
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      ,'YYYY-MM-DD HH24:MI:SS')
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_source_request_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ,p_source_request_id
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          FROM dual)
     WHERE wst.step_transaction_id = l_step_transaction_id;

    -- Adjust package data
    UPDATE kdlv_packages p
       SET p.parent_step_transaction_id = l_step_transaction_id
     WHERE p.package_id = o_package_id;

    o_message := 'OK';
    return g_success;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR: SQL Error Code: ' || SQLCODE);
      dbms_output.put_line('ERROR: ' || SQLERRM);
      o_message := 'Oracle Error: ' || SQLCODE || ' : ' || SQLERRM;
      RETURN g_failure;
  END create_pkg_from_req;

  FUNCTION add_pkg_to_rel(p_package_id        IN kdlv_packages.package_id%TYPE
                         ,p_release_id        IN krel_releases.release_id%TYPE
                         ,p_added_by_username IN knta_users.username%TYPE
                         ,o_message           OUT VARCHAR2) RETURN VARCHAR2 IS
    l_package_id       kdlv_packages.package_id%TYPE;
    l_release_id       krel_releases.release_id%TYPE;
    l_added_by_user_id knta_users.user_id%TYPE;

    l_reference_id   knta_references.reference_id%TYPE;
    l_reverse_ref_id knta_references.reference_id%TYPE;

    l_creation_date    DATE;
    l_last_update_date DATE;
    l_message_type     NUMBER;
    l_message_name     VARCHAR2(100);
    l_message          VARCHAR2(2000);
  BEGIN
    -- Check parameters: Is the release still open?
    o_message := 'ERROR: Release "' || p_release_id ||
                 '" does not exist or is not open.';
    SELECT r.release_id
      INTO l_release_id
      FROM krel_releases r
     WHERE r.release_id = p_release_id AND r.parameter2 = 'Open';
    -- Check parameters: Does the user exist?
    o_message := 'ERROR: User "' || p_added_by_username ||
                 '" does not exist.';
    SELECT u.user_id
      INTO l_added_by_user_id
      FROM knta_users u
     WHERE u.username = p_added_by_username;
    -- Check parameters: Does the package exist?
    o_message := 'ERROR: Package No. ' || p_package_id ||
                 ' does not exist.';
    SELECT p.package_id
      INTO l_package_id
      FROM kdlv_packages p
     WHERE p.package_id = p_package_id;

    -- Parameters Ok. Now add package to release by creating two-way references.
    l_reference_id := NULL;
    knta_references_th.Process_Row(p_event               => 'INSERT'
                                  ,p_reference_id        => l_reference_id
                                  ,p_last_updated_by     => l_added_by_user_id
                                  ,p_target_type_code    => knta_constant.ENTITY_RELEASE
                                  ,p_ref_relationship_id => knta_constant.REF_PKG_CONTAINED_IN_RELEASE
                                  ,p_source_entity_id    => knta_constant.ENTITY_PACKAGE
                                  ,p_enabled_flag        => 'Y'
                                  ,p_source_id           => p_package_id
                                  ,p_original_source_id  => p_package_id
                                  ,p_parameter1          => l_release_id
                                  ,o_last_update_date    => l_last_update_date
                                  ,o_creation_date       => l_creation_date
                                  ,o_message_type        => l_message_type
                                  ,o_message_name        => l_message_name
                                  ,o_message             => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      dbms_output.put_line('ERROR: Message-Type "' || l_message_type);
      dbms_output.put_line('ERROR: Message-Name "' || l_message_name);
      dbms_output.put_line('ERROR: Message      "' || l_message);
      o_message := 'ERROR: Cannot create reference from package to release.';
      return g_failure;
    end if;

    -- Add reverse reference
    l_reverse_ref_id := NULL;
    knta_references_th.Process_Row(p_event                => 'INSERT'
                                  ,p_reference_id         => l_reverse_ref_id
                                  ,p_reverse_reference_id => l_reference_id
                                  ,p_last_updated_by      => l_added_by_user_id
                                  ,p_target_type_code     => knta_constant.ENTITY_PACKAGE
                                  ,p_ref_relationship_id  => knta_constant.REF_RELEASE_CONTAINS_PKG
                                  ,p_source_entity_id     => knta_constant.ENTITY_RELEASE
                                  ,p_enabled_flag         => 'Y'
                                  ,p_source_id            => l_release_id
                                  ,p_original_source_id   => l_release_id
                                  ,p_parameter1           => p_package_id
                                  ,o_last_update_date     => l_last_update_date
                                  ,o_creation_date        => l_creation_date
                                  ,o_message_type         => l_message_type
                                  ,o_message_name         => l_message_name
                                  ,o_message              => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      dbms_output.put_line('ERROR: Message-Type "' || l_message_type);
      dbms_output.put_line('ERROR: Message-Name "' || l_message_name);
      dbms_output.put_line('ERROR: Message      "' || l_message);
      o_message := 'ERROR: Cannot create reference from package to release.';
      return g_failure;
    end if;

    -- Ok. Function executed successfully.
    o_message := 'add_pkg_to_rel() executed successfully.';
    return g_success;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR: SQL Error Code: ' || SQLCODE);
      dbms_output.put_line('ERROR: ' || SQLERRM);
      return g_failure;
  END add_pkg_to_rel;

  ---------------------------------------------------------------------------------------------------
  FUNCTION add_request_to_rel(p_request_id        IN kcrt_requests.request_id%TYPE
                             ,p_release_id        IN krel_releases.release_id%TYPE
                             ,p_added_by_username IN knta_users.username%TYPE
                             ,o_message           OUT VARCHAR2)
    RETURN VARCHAR2 IS
    l_request_id       kcrt_requests.request_id%TYPE;
    l_release_id       krel_releases.release_id%TYPE;
    l_added_by_user_id knta_users.user_id%TYPE;

    l_reference_id   knta_references.reference_id%TYPE;
    l_reverse_ref_id knta_references.reference_id%TYPE;

    l_creation_date    DATE;
    l_last_update_date DATE;
    l_message_type     NUMBER;
    l_message_name     VARCHAR2(100);
    l_message          VARCHAR2(2000);
  BEGIN
    -- Check parameters: Is the release still open?
    o_message := 'ERROR: Release "' || p_release_id ||
                 '" does not exist or is not open.';
    SELECT r.release_id
      INTO l_release_id
      FROM krel_releases r
     WHERE r.release_id = p_release_id AND r.parameter2 = 'Open';
    -- Check parameters: Does the user exist?
    o_message := 'ERROR: User "' || p_added_by_username ||
                 '" does not exist.';
    SELECT u.user_id
      INTO l_added_by_user_id
      FROM knta_users u
     WHERE u.username = p_added_by_username;
    -- Check parameters: Does the request exist?
    o_message := 'ERROR: Request No. ' || p_request_id ||
                 ' does not exist.';
    SELECT r.request_id
      INTO l_request_id
      FROM kcrt_requests r
     WHERE r.request_id = p_request_id;

    -- Parameters Ok. Now add request to release by creating two-way references.
    l_reference_id := NULL;
    knta_references_th.Process_Row(p_event               => 'INSERT'
                                  ,p_reference_id        => l_reference_id
                                  ,p_last_updated_by     => l_added_by_user_id
                                  ,p_target_type_code    => knta_constant.ENTITY_RELEASE
                                  ,p_ref_relationship_id => knta_constant.REF_REQUEST_CONTAINED_IN_REL
                                  ,p_source_entity_id    => knta_constant.ENTITY_REQUEST
                                  ,p_enabled_flag        => 'Y'
                                  ,p_source_id           => p_request_id
                                  ,p_original_source_id  => p_request_id
                                  ,p_parameter1          => l_release_id
                                  ,o_last_update_date    => l_last_update_date
                                  ,o_creation_date       => l_creation_date
                                  ,o_message_type        => l_message_type
                                  ,o_message_name        => l_message_name
                                  ,o_message             => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      dbms_output.put_line('ERROR: Message-Type "' || l_message_type);
      dbms_output.put_line('ERROR: Message-Name "' || l_message_name);
      dbms_output.put_line('ERROR: Message      "' || l_message);
      o_message := 'ERROR: Cannot create reference from request to release.';
      return g_failure;
    end if;

    -- Add reverse reference
    l_reverse_ref_id := NULL;
    knta_references_th.Process_Row(p_event                => 'INSERT'
                                  ,p_reference_id         => l_reverse_ref_id
                                  ,p_reverse_reference_id => l_reference_id
                                  ,p_last_updated_by      => l_added_by_user_id
                                  ,p_target_type_code     => knta_constant.ENTITY_REQUEST
                                  ,p_ref_relationship_id  => knta_constant.REF_RELEASE_CONTAINS_REQUEST
                                  ,p_source_entity_id     => knta_constant.ENTITY_RELEASE
                                  ,p_enabled_flag         => 'Y'
                                  ,p_source_id            => l_release_id
                                  ,p_original_source_id   => l_release_id
                                  ,p_parameter1           => p_request_id
                                  ,o_last_update_date     => l_last_update_date
                                  ,o_creation_date        => l_creation_date
                                  ,o_message_type         => l_message_type
                                  ,o_message_name         => l_message_name
                                  ,o_message              => l_message);
    if (l_message_type != knta_constant.SUCCESS) then
      dbms_output.put_line('ERROR: Message-Type "' || l_message_type);
      dbms_output.put_line('ERROR: Message-Name "' || l_message_name);
      dbms_output.put_line('ERROR: Message      "' || l_message);
      o_message := 'ERROR: Cannot create reference from request to release.';
      return g_failure;
    end if;

    -- Ok. Function executed successfully.
    o_message := 'add_request_to_rel() executed successfully.';
    return g_success;

  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('ERROR: SQL Error Code: ' || SQLCODE);
      dbms_output.put_line('ERROR: ' || SQLERRM);
      return g_failure;
  END add_request_to_rel;
  ---------------------------------------------------------------------------------------------------
  /*
  * get_next_pkgl_seq() returns the next package line sequence number or NULL, if no
  * more package lines exist.
  *
  * Parameter:
  *    p_package_id        The package containing the package lines
  *    p_package_line_seq  The current package line sequence number
  *
  * Returns:
  *    NULL                The given p_package_line_seq is the last line in the package
  *    n                   The next package line sequence number is n
  */
  FUNCTION get_next_pkgl_seq(p_package_id       IN kdlv_packages.package_id%TYPE
                            ,p_package_line_seq IN kdlv_package_lines.seq%TYPE)
    RETURN kdlv_package_lines.seq%TYPE IS
    l_result kdlv_package_lines.seq%TYPE;
  BEGIN
    -- Determine next package line
    SELECT min(pl.seq)
      INTO l_result
      FROM kdlv_package_lines pl
     WHERE pl.package_id = p_package_id AND pl.seq > p_package_line_seq;

    return l_result;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return NULL;
  END get_next_pkgl_seq;

  /*
  * get_package_created_username() returns the name of the packages creator.
  *
  * Parameter:
  *    p_package_id        The package ID
  *
  * Returns:
  *    NULL                The given p_package_id does not exist
  *    username            Name of the creator of the package
  */
  FUNCTION get_package_created_username(p_package_id IN kdlv_packages.package_id%TYPE)
    RETURN knta_users.username%TYPE IS
    l_result knta_users.username%TYPE;
  BEGIN
    -- Determine creator of package
    SELECT u.username
      INTO l_result
      FROM kdlv_packages p, knta_users u
     WHERE p.package_id = p_package_id AND p.created_by = u.user_id;

    return l_result;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      return NULL;
  END get_package_created_username;

  FUNCTION run_next_pkgl(p_package_id           IN kdlv_packages.package_id%TYPE
                        ,p_package_line_seq     IN kdlv_package_lines.seq%TYPE
                        ,p_workflow_step_seq    IN kwfl_workflow_steps.sort_order%TYPE
                        ,p_visible_result_value IN kwfl_step_transitions.visible_result_value%TYPE
                        ,o_message              OUT VARCHAR2) RETURN VARCHAR2 IS
    l_package_creator knta_users.username%TYPE;
    l_next_pkgl_seq   kdlv_package_lines.seq%TYPE;
    l_group_id        kwfl_transactions_int.group_id%TYPE;
    l_result          VARCHAR2(20) := g_failure;

    l_message_type NUMBER;
    l_message_name VARCHAR2(100);
    l_message      VARCHAR2(2000);

    l_errors   c_get_errors%ROWTYPE;
    l_warnings c_get_warnings%ROWTYPE;
  BEGIN
    o_message := 'OK';

    -- Get package creator
    l_package_creator := get_package_created_username(p_package_id);
    if (l_package_creator IS NULL) then
      l_package_creator := 'admin';
    end if;

    -- Get next package line sequence number
    l_next_pkgl_seq := get_next_pkgl_seq(p_package_id, p_package_line_seq);
    if (l_next_pkgl_seq IS NULL) then
      -- p_package_line_seq is the last line in the package => no action necessary
      o_message := 'WARNING: No more package lines found.';
      l_result  := g_success;
    else
      -- run next package line
      SELECT knta_interface_groups_s.nextval INTO l_group_id FROM dual;

      kwfl_txn_int.insert_row(p_event                 => 'APPROVAL_VOTE'
                             ,p_group_id              => l_group_id
                             ,p_created_username      => l_package_creator
                             ,p_source                => NULL
                             ,p_request_number        => NULL
                             ,p_package_number        => p_package_id
                             ,p_package_line_seq      => l_next_pkgl_seq
                             ,p_workflow_step_name    => NULL
                             ,p_workflow_step_seq     => p_workflow_step_seq
                             ,p_visible_result_value  => p_visible_result_value
                             ,p_user_comments         => NULL
                             ,p_delegated_to_username => NULL
                             ,p_schedule_date         => NULL
                             ,p_to_workflow_step_name => NULL
                             ,p_to_workflow_step_seq  => NULL
                             ,O_MESSAGE_TYPE          => l_message_type
                             ,O_MESSAGE_NAME          => l_message_name
                             ,O_MESSAGE               => l_message);
      if (l_message_type != knta_constant.SUCCESS) then
        -- insert_row failed, return error
        o_message := 'ERROR: kwfl_txn_int.insert_row() ' || l_message_name || ': ' ||
                     l_message;
        l_result  := g_failure;
      else
        -- insert_row succeeded, run interface
        kwfl_txn_int.run_interface(p_group_id     => l_group_id
                                  ,p_usr_dbg      => knta_constant.DEBUG_ALL
                                  ,p_user_id      => 1
                                  ,o_message_type => l_message_type
                                  ,o_message_name => l_message_name
                                  ,o_message      => l_message);
        if (l_message_type != knta_constant.SUCCESS) then
          -- run interface failed, return error
          o_message := 'ERROR: kwfl_txn_int.run_interface() ' ||
                       l_message_name || ': ' || l_message;
          l_result  := g_failure;
        else
          -- run interface succeeded, get warnings and errors
          l_result := g_success;
          OPEN c_get_errors(l_group_id);
          FETCH c_get_errors
            INTO l_errors;
          WHILE c_get_errors%FOUND LOOP
            l_result := g_failure;
            dbms_output.put_line('ERROR: ' || l_errors.message_name);
            dbms_output.put_line('ERROR: ' || l_errors.message);
            o_message := 'ERROR: ' || l_errors.message_name || ': ' ||
                         l_errors.message;
            FETCH c_get_errors
              INTO l_errors;
          END LOOP;
          CLOSE c_get_errors;

          OPEN c_get_warnings(l_group_id);
          FETCH c_get_warnings
            INTO l_warnings;
          WHILE c_get_warnings%FOUND LOOP
            dbms_output.put_line('WARNING: ' || l_warnings.message_name);
            dbms_output.put_line('WARNING: ' || l_warnings.message);
            FETCH c_get_warnings
              INTO l_warnings;
          END LOOP;
          CLOSE c_get_warnings;
        end if;
      end if;
    end if;

    return l_result;

  EXCEPTION
    WHEN OTHERS THEN
      o_message := 'ERROR: ' || SQLCODE || ' - ' || SQLERRM;
      return g_failure;
  END run_next_pkgl;

END BETEO_kdlv_util;
/
 