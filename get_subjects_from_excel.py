�
k�
Qc           @   s�   d  Z  d Z d d l m Z e d e � Z e j d Z i  Z d Z x� e j	 d e
 e � � j d k	 r� e j	 d e
 e � � j d	 k r� e
 e j	 d
 e
 e � � j � e e
 e j	 d e
 e � � j � <n  e d Z qG Wd S(   s�    Script to return a dictionary subjs with the string name and subject status
    from the Excel spreadsheet that Bethany keeps.
sC   /Users/sudregp/Documents/Bethany_MEGRest_Analysis_Notes_Sept11.xlsxi����(   t   load_workbookt   filenamei    i   t   At   Ft   Yt   Lt   DN(   t   __doc__t   fnamet   openpyxl.reader.excelR    t   wbt
   worksheetst   wst   subjst   cntt   cellt   strt   valuet   None(    (    (    s7   /Users/sudregp/research_code/get_subjects_from_excel.pyt   <module>   s   %"E