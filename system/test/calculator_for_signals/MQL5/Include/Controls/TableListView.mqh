//+------------------------------------------------------------------+
//|                                                TableListView.mqh |
//|                   Copyright 2009-2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property version "2.076"
#include "WndClient.mqh"
#include "Edit.mqh"
#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayLong.mqh>
//+------------------------------------------------------------------+
//| Class CTableListView                                             |
//| Usage: display lists                                             |
//+------------------------------------------------------------------+
class CTableListView : public CWndClient
  {
private:
   //--- dependent controls
   CArrayObj         m_arr_rows;             // array of pointer to objects-rows (CEdit) 
   //--- set up
   int               m_offset;              // index of first visible row in array of rows
   int               m_total_view;          // number of visible rows
   int               m_item_height;         // height of visible row
   bool              m_height_variable;     // признак переменной высоты списка
   uchar             m_columns;              // number of columns in a table
   ushort            m_columns_size[];       // array of columns size (in pixels)
                                             //int
   //--- data
   CArrayObj         m_arr_rows_str;         // array of pointer to objects-rows (CArrayString) 
   CArrayObj         m_arr_rows_val;         // array of pointer to objects-rows (CArrayLong) 
   int               m_current_row;          // index of current row in array of rows
   int               m_current_col;          // index of current columns in array of columns    

public:
                     CTableListView(void);
                    ~CTableListView(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,
                            const int y1,const int x2,const int y2,const uchar columns,const ushort &columns_size[]);
   virtual void      Destroy(const int reason=0);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- set up
   bool              TotalView(const int value);
   //--- fill
   virtual bool      AddItem(const string &item[],const long &value[]);
   //--- data
   virtual bool      ItemAdd(const string &item[],const long &value[]);
   virtual bool      ItemInsert(const int index,const string item,const long value=0);
   virtual bool      ItemUpdate(const int index,const string item,const long value=0);
   virtual bool      ItemDelete(const int index);
   virtual bool      ItemsClear(void);
   //--- data
   bool              Current(int &row,int &col) { row=m_current_row;col=m_current_col;return(true); }
   string            GetText(const int index_row,const int index_column);
   bool              Select(const int index_row,const int index_column);
   bool              SelectByText(const string text);
   bool              SelectByValue(const long value);
   //--- data (read only)
   //long              Value(void) { return(m_values.At(m_current));  }
   //--- state
   virtual bool      Show(void);
   bool              TextAlign(const int index_column,const ENUM_ALIGN_MODE align);

protected:
   //--- create dependent controls
   bool              CreateRow(const int index);
   //--- event handlers
   virtual bool      OnResize(void);
   //--- handlers of the dependent controls events
   virtual bool      OnVScrollShow(void);
   virtual bool      OnVScrollHide(void);
   virtual bool      OnScrollLineDown(void);
   virtual bool      OnScrollLineUp(void);
   virtual bool      OnItemClick(const int index_row,const int index_column);
   //--- redraw
   bool              Redraw(void);
   bool              RowState(const int index,const bool select);
   bool              CheckView(void);
  };
//+------------------------------------------------------------------+
//| Common handler of chart events                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CTableListView)
if(id==(ON_CLICK+CHARTEVENT_CUSTOM))
  {
   int total=m_arr_rows.Total();
   for(int i=0;i<total;i++)
     {
      CArrayObj *m_arr_cells=m_arr_rows.At(i);
      if(CheckPointer(m_arr_cells)==POINTER_INVALID)
         return(false);
      for(int j=0;j<m_columns;j++)
        {
         CEdit *m_cell=m_arr_cells.At(j);
         if(CheckPointer(m_cell)==POINTER_INVALID)
            return(false);
         long id_cell=m_cell.Id();
         //Print("id_cell=",id_cell,"; lparam=",lparam);
         if(lparam==id_cell)
            return(OnItemClick(i,j));
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EVENT_MAP_END(CWndClient)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTableListView::CTableListView(void) : m_offset(0),
                                       m_total_view(0),
                                       m_item_height(CONTROLS_LIST_ITEM_HEIGHT),
                                       m_current_row(CONTROLS_INVALID_INDEX),
                                       m_current_col(CONTROLS_INVALID_INDEX),
                                       m_height_variable(false)
  {

  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTableListView::~CTableListView(void)
  {

  }
//+------------------------------------------------------------------+
//| Create a control                                                 |
//+------------------------------------------------------------------+
bool CTableListView::Create(const long chart,const string name,const int subwin,const int x1,
                            const int y1,const int x2,const int y2,const uchar columns,const ushort &columns_size[])
  {
   m_columns=columns;
   ArrayResize(m_columns_size,m_columns);
   if(ArraySize(columns_size)!=m_columns)
      return(false);
   ArrayCopy(m_columns_size,columns_size,0,0,WHOLE_ARRAY);
   m_columns_size[0]-=1;
   m_columns_size[m_columns-1]-=1;
   int y=y2;
//--- if the number of visible rows is previously determined, adjust the vertical size
   if(!TotalView((y2-y1)/m_item_height))
      y=m_item_height+y1+2*CONTROLS_BORDER_WIDTH;
//--- check the number of visible rows
   if(m_total_view<1)
      return(false);
//--- call method of the parent class
   if(!CWndClient::Create(chart,name,subwin,x1,y1,x2,y))
      return(false);
//--- set up
   if(!m_background.ColorBackground(CONTROLS_LIST_COLOR_BG))
      return(false);
   if(!m_background.ColorBorder(CONTROLS_LIST_COLOR_BORDER))
      return(false);
//--- create dependent controls
   CArrayObj *m_arr_cells;
   for(int i=0;i<m_total_view;i++)
     {
      m_arr_cells=new CArrayObj;
      if(CheckPointer(m_arr_cells)==POINTER_INVALID)
         return(false);
      for(int j=0;j<m_columns;j++)
        {
         CEdit *m_cell;
         m_cell=new CEdit;
         if(CheckPointer(m_cell)==POINTER_INVALID)
            return(false);
         m_arr_cells.Add(m_cell);
        }
      m_arr_rows.Add(m_arr_cells);
     }
//---
   for(int i=0;i<m_total_view;i++)
     {
      if(!CreateRow(i))
         return(false);
      if(m_height_variable && i>0)
        {
         // m_rows[i].Hide(); ///
         CArrayObj *m_arr_cells_i=m_arr_rows.At(i);
         if(CheckPointer(m_arr_cells_i)==POINTER_INVALID)
            return(false);
         for(int j=0;j<m_arr_cells_i.Total();j++)
           {
            CEdit *m_cell=m_arr_cells_i.At(j);
            if(CheckPointer(m_cell)==POINTER_INVALID)
               return(false);
            if(!m_cell.Hide())
               return(false);
           }
        }
     }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Delete group of controls                                         |
//+------------------------------------------------------------------+
void CTableListView::Destroy(const int reason)
  {
//--- call of the method of the parent class
   CWndClient::Destroy(reason);
//--- clear items
   m_arr_rows.Clear();
   m_arr_rows_str.Clear();
   m_arr_rows_val.Clear();
//---
   m_offset    =0;
   m_total_view=0;
  }
//+------------------------------------------------------------------+
//| Set parameter                                                    |
//+------------------------------------------------------------------+
bool CTableListView::TotalView(const int value)
  {
//--- if parameter is not equal to 0, modifications are not possible
   if(m_total_view!=0)
     {
      m_height_variable=true;
      return(false);
     }
//--- save value
   m_total_view=value;
//--- parameter has been changed
   return(true);
  }
//+------------------------------------------------------------------+
//| Makes the control visible                                        |
//+------------------------------------------------------------------+
bool CTableListView::Show(void)
  {
//--- call of the method of the parent class
   CWndClient::Show();
//--- number of items
   int total=m_arr_rows_str.Total();
//---
   if(total==0)
      total=1;
//---
   if(m_height_variable && total<m_total_view)
      for(int i=total;i<m_total_view;i++)
        {
         CArrayObj *m_arr_cells=m_arr_rows.At(i);
         if(CheckPointer(m_arr_cells)==POINTER_INVALID)
            return(false);
         for(int j=0;j<m_arr_cells.Total();j++)
           {
            CEdit *m_cell=m_arr_cells.At(j);
            if(CheckPointer(m_cell)==POINTER_INVALID)
               return(false);
            m_cell.Hide();
           }
        }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|  Align text in columns                                           |
//+------------------------------------------------------------------+
bool CTableListView::TextAlign(const int index_column,const ENUM_ALIGN_MODE align)
  {
//--- check index
   if(index_column<0 || index_column>=m_columns)
      return(false);
//--- number of items
   int total=m_arr_rows.Total();
   for(int i=0;i<total;i++)
     {
      CArrayObj *m_arr_cells=m_arr_rows.At(i);
      if(CheckPointer(m_arr_cells)==POINTER_INVALID)
         return(false);
      CEdit *m_cell=m_arr_cells.At(index_column);
      if(CheckPointer(m_cell)==POINTER_INVALID)
         return(false);
      if(!m_cell.TextAlign(align))
         return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create "row"                                                     |
//+------------------------------------------------------------------+
bool CTableListView::CreateRow(const int index)
  {
//--- calculate coordinates
   int x1=CONTROLS_BORDER_WIDTH;
   int y1=CONTROLS_BORDER_WIDTH+m_item_height*index;
   int x2=0; //Width()-2*CONTROLS_BORDER_WIDTH-CONTROLS_SCROLL_SIZE+1; ///
   int y2=y1+m_item_height;
//--- create
   CArrayObj *m_arr_cells=m_arr_rows.At(index);
   if(CheckPointer(m_arr_cells)==POINTER_INVALID)
      return(false);
   for(int i=0;i<m_arr_cells.Total();i++)
     {
      CEdit *m_cell=m_arr_cells.At(i);
      if(CheckPointer(m_cell)==POINTER_INVALID)
         return(false);
      x1+=x2;
      x2=m_columns_size[i];
      if(!m_cell.Create(m_chart_id,m_name+"_"+IntegerToString(index)+"_"+IntegerToString(i),
         m_subwin,x1,y1,x1+x2,y2))
         return(false);
      if(!m_cell.Text(""))
         return(false);
      if(!m_cell.ReadOnly(true))
         return(false);
      if(!Add(m_cell))
         return(false);
     }
   if(!RowState(index,false))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Add item (row)                                                   |
//+------------------------------------------------------------------+
bool CTableListView::AddItem(const string &item[],const long &value[])
  {
//--- method left for compatibility with previous version
   return(ItemAdd(item,value));
  }
//+------------------------------------------------------------------+
//| Add item (row)                                                   |
//+------------------------------------------------------------------+
bool CTableListView::ItemAdd(const string &item[],const long &value[])
  {
//--- check size of array
   if(ArraySize(item)!=m_columns || ArraySize(value)!=m_columns)
      return(false);
//--- add
   CArrayString *m_arr_cells_strings;
   m_arr_cells_strings=new CArrayString;
   if(CheckPointer(m_arr_cells_strings)==POINTER_INVALID)
      return(false);
   m_arr_cells_strings.AssignArray(item);
   m_arr_rows_str.Add(m_arr_cells_strings);

   CArrayLong *m_arr_cells_values;
   m_arr_cells_values=new CArrayLong;
   if(CheckPointer(m_arr_cells_values)==POINTER_INVALID)
      return(false);
   m_arr_cells_values.AssignArray(value);
   m_arr_rows_val.Add(m_arr_cells_values);

//--- number of items
   int total=m_arr_rows_str.Total();
//--- exit if number of items does not exceed the size of visible area
   if(total<m_total_view+1)
     {
      if(m_height_variable && total!=1)
        {
         Height(total*m_item_height+2*CONTROLS_BORDER_WIDTH);
         if(IS_VISIBLE)
           {
            CArrayObj *m_arr_cells=m_arr_rows.At(total-1);
            if(CheckPointer(m_arr_cells)==POINTER_INVALID)
               return(false);
            for(int i=0;i<m_arr_cells.Total();i++)
              {
               CEdit *m_cell=m_arr_cells.At(i);
               if(CheckPointer(m_cell)==POINTER_INVALID)
                  return(false);
               m_cell.Show();
              }
           }
        }
      return(Redraw());
     }
//--- if number of items exceeded the size of visible area
   if(total==m_total_view+1)
     {
      //--- enable vertical scrollbar
      if(!VScrolled(true))
         return(false);
      //--- and immediately make it invisible (if needed)
      if(IS_VISIBLE && !OnVScrollShow())
         return(false);
     }
//--- set up the scrollbar
   m_scroll_v.MaxPos(m_arr_rows_str.Total()-m_total_view);
//--- redraw
   return(Redraw());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*//+------------------------------------------------------------------+
//| Insert item (row)                                                |
//+------------------------------------------------------------------+
bool CTableListView::ItemInsert(const int index,const string item,const long value)
  {
//--- insert
   if(!m_strings.Insert(item,index))
      return(false);
   if(!m_values.Insert(value,index))
      return(false);
//--- number of items
   int total=m_strings.Total();
//--- exit if number of items does not exceed the size of visible area
   if(total<m_total_view+1)
     {
      if(m_height_variable && total!=1)
        {
         Height(total*m_item_height+2*CONTROLS_BORDER_WIDTH);
         if(IS_VISIBLE)
            m_rows[total-1].Show();
        }
      return(Redraw());
     }
//--- if number of items exceeded the size of visible area
   if(total==m_total_view+1)
     {
      //--- enable vertical scrollbar
      if(!VScrolled(true))
         return(false);
      //--- and immediately make it invisible (if needed)
      if(IS_VISIBLE && !OnVScrollShow())
         return(false);
     }
//--- set up the scrollbar
   m_scroll_v.MaxPos(m_strings.Total()-m_total_view);
//--- redraw
   return(Redraw());
  }*/
/*//+------------------------------------------------------------------+
//| Update item (row)                                                |
//+------------------------------------------------------------------+
bool CTableListView::ItemUpdate(const int index,const string item,const long value)
  {
//--- update
   if(!m_strings.Update(index,item))
      return(false);
   if(!m_values.Update(index,value))
      return(false);
//--- redraw
   return(Redraw());
  }*/
/*//+------------------------------------------------------------------+
//| Delete item (row)                                                |
//+------------------------------------------------------------------+
bool CTableListView::ItemDelete(const int index)
  {
//--- delete
   if(!m_strings.Delete(index))
      return(false);
   if(!m_values.Delete(index))
      return(false);
//--- number of items
   int total=m_strings.Total();
//--- exit if number of items does not exceed the size of visible area
   if(total<m_total_view)
     {
      if(m_height_variable && total!=0)
        {
         Height(total*m_item_height+2*CONTROLS_BORDER_WIDTH);
         m_rows[total].Hide();
        }
      return(Redraw());
     }
//--- if number of items exceeded the size of visible area
   if(total==m_total_view)
     {
      //--- disable vertical scrollbar
      if(!VScrolled(false))
         return(false);
      //--- and immediately make it unvisible
      if(!OnVScrollHide())
         return(false);
     }
//--- set up the scrollbar
   m_scroll_v.MaxPos(m_strings.Total()-m_total_view);
//--- redraw
   return(Redraw());
  }*/
//+------------------------------------------------------------------+
//| Delete all items                                                 |
//+------------------------------------------------------------------+
bool CTableListView::ItemsClear(void)
  {
   m_offset=0;
//--- clear
   if(!m_arr_rows_str.Shutdown())
      return(false);
   if(!m_arr_rows_val.Shutdown())
      return(false);
//---
   if(m_height_variable)
     {
      Height(m_item_height+2*CONTROLS_BORDER_WIDTH);
      for(int i=1;i<m_total_view;i++)
        {
         //m_rows[i].Hide(); ///
         CArrayObj *m_arr_cells_i=m_arr_rows.At(i);
         if(CheckPointer(m_arr_cells_i)==POINTER_INVALID)
            return(false);
         for(int j=0;j<m_arr_cells_i.Total();j++)
           {
            CEdit *m_cell=m_arr_cells_i.At(j);
            if(CheckPointer(m_cell)==POINTER_INVALID)
               return(false);
            if(!m_cell.Hide())
               return(false);
           }
        }
     }
//--- disable vertical scrollbar
   if(!VScrolled(false))
      return(false);
//--- and immediately make it unvisible (if needed)
   if(!OnVScrollHide())
      return(false);
//--- redraw
   return(Redraw());
  }
//+------------------------------------------------------------------+
//| Get text                                                         |
//+------------------------------------------------------------------+
string CTableListView::GetText(const int index_row,const int index_column)
  {
  //--- check index
   if(index_row>=m_arr_rows_str.Total() || index_column>=m_columns)
      return(NULL);
   if(index_row<0 || index_column<0)
      return(NULL);
   CArrayString *m_arr_cells_strings=m_arr_rows_str.At(index_row);
   if(CheckPointer(m_arr_cells_strings)==POINTER_INVALID)
      return(NULL);
   return(m_arr_cells_strings.At(index_column));
  }
//+------------------------------------------------------------------+
//| Set current item                                                 |
//+------------------------------------------------------------------+
bool CTableListView::Select(const int index_row,const int index_column)
  {
//--- check index
   if(index_row>=m_arr_rows_str.Total())
      return(false);
   if(index_row<0 && index_row!=CONTROLS_INVALID_INDEX)
      return(false);
//--- unselect
   if(m_current_row!=CONTROLS_INVALID_INDEX)
      RowState(m_current_row-m_offset,false);
//--- select
   if(index_row!=CONTROLS_INVALID_INDEX)
      RowState(index_row-m_offset,true);
//--- save value
   m_current_row=index_row;
   m_current_col=index_column;
//--- succeed
   return(CheckView());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*//+------------------------------------------------------------------+
//| Set current item (by text)                                       |
//+------------------------------------------------------------------+
bool CTableListView::SelectByText(const string text)
  {
//--- find text
   int index=m_strings.SearchLinear(text);
//--- if text is not found, exit without changing the selection
   if(index==CONTROLS_INVALID_INDEX)
      return(false);
//--- change selection
   return(Select(index));
  }*/
/*//+------------------------------------------------------------------+
//| Set current item (by value)                                      |
//+------------------------------------------------------------------+
bool CTableListView::SelectByValue(const long value)
  {
//--- find value
   int index=m_values.SearchLinear(value);
//--- if value is not found, exit without changing the selection
   if(index==CONTROLS_INVALID_INDEX)
      return(false);
//--- change selection
   return(Select(index));
  }*/
//+------------------------------------------------------------------+
//| Redraw                                                           |
//+------------------------------------------------------------------+
bool CTableListView::Redraw(void)
  {
//--- loop by "rows"
   int m=(m_total_view>m_arr_rows_str.Total())?m_arr_rows_str.Total():m_total_view;
   for(int i=0;i<m;i++)
     {
      //--- copy text
      CArrayObj *m_arr_cells=m_arr_rows.At(i);
      if(CheckPointer(m_arr_cells)==POINTER_INVALID)
         return(false);

      CArrayString *m_arr_cells_strings=m_arr_rows_str.At(i+m_offset);
      if(CheckPointer(m_arr_cells_strings)==POINTER_INVALID)
         return(false);

      for(int j=0;j<m_columns;j++)
        {
         CEdit *m_cell=m_arr_cells.At(j);
         if(CheckPointer(m_cell)==POINTER_INVALID)
            return(false);

         if(!m_cell.Text(m_arr_cells_strings.At(j)))
            return(false);
        }
      //--- select
      if(!RowState(i,(m_current_row==i+m_offset)))
         return(false);
     }
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Change state                                                     |
//+------------------------------------------------------------------+
bool CTableListView::RowState(const int index,const bool select)
  {
//--- check index
   if(index<0 || index>=m_arr_rows.Total())
      return(true);
//--- determine colors
   color  text_color=(select) ? CONTROLS_LISTITEM_COLOR_TEXT_SEL : CONTROLS_LISTITEM_COLOR_TEXT;
   color  back_color=(select) ? CONTROLS_LISTITEM_COLOR_BG_SEL : CONTROLS_LISTITEM_COLOR_BG;
//--- get pointer to row
   CArrayObj *m_arr_cells=m_arr_rows.At(index);
   if(CheckPointer(m_arr_cells)==POINTER_INVALID)
      return(false);
////debug ///
//   Print(__FUNCTION__,": Total in the m_arr_cells: ",m_arr_cells.Total()); ///
   bool result=true;
   for(int i=0;i<m_arr_cells.Total();i++)
     {
      CEdit *m_cell=m_arr_cells.At(i);
      if(CheckPointer(m_cell)==POINTER_INVALID)
         return(false);
      //--- recolor the "row"
      result=(result && (m_cell.Color(text_color) && m_cell.ColorBackground(back_color) && m_cell.ColorBorder(back_color)));
     }
   return(result);
  }
//+------------------------------------------------------------------+
//| Check visibility of selected row                                 |
//+------------------------------------------------------------------+
bool CTableListView::CheckView(void)
  {
//--- check visibility
   if(m_current_row>=m_offset && m_current_row<m_offset+m_total_view)
      return(true);
//--- selected row is not visible
   int total=m_arr_rows_str.Total();
   m_offset=(total-m_current_row>m_total_view) ? m_current_row : total-m_total_view;
//--- adjust the scrollbar
   m_scroll_v.CurrPos(m_offset);
//--- redraw
   return(Redraw());
  }
//+------------------------------------------------------------------+
//| Handler of resizing                                              |
//+------------------------------------------------------------------+
bool CTableListView::OnResize(void)
  {
//--- call of the method of the parent class
   if(!CWndClient::OnResize())
      return(false);
//--- set up the size of "row"
   if(VScrolled())
      OnVScrollShow();
   else
      OnVScrollHide();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Handler of the "Show vertical scrollbar" event                   |
//+------------------------------------------------------------------+
bool CTableListView::OnVScrollShow(void)
  {
//--- loop by "rows"
   int total=m_arr_rows.Total();
   for(int i=0;i<total;i++)
     {
      CArrayObj *m_arr_cells=m_arr_rows.At(i);
      if(CheckPointer(m_arr_cells)==POINTER_INVALID)
         return(false);
      CEdit *m_cell=m_arr_cells.At(m_columns-1);
      if(CheckPointer(m_cell)==POINTER_INVALID)
         return(false);
      //--- resize "rows" according to shown vertical scrollbar
      if(!m_cell.Width(m_columns_size[m_columns-1]-(CONTROLS_SCROLL_SIZE+CONTROLS_BORDER_WIDTH)))
         return(false);
     }
//--- check visibility
   if(!IS_VISIBLE)
     {
      m_scroll_v.Visible(false);
      return(true);
     }
//--- event is handled
   return(true);
  }
//+------------------------------------------------------------------+
//| Handler of the "Hide vertical scrollbar" event                   |
//+------------------------------------------------------------------+
bool CTableListView::OnVScrollHide(void)
  {
//--- check visibility
   if(!IS_VISIBLE)
      return(true);
//--- loop by "rows"
   int total=m_arr_rows.Total();
   for(int i=0;i<total;i++)
     {
      CArrayObj *m_arr_cells=m_arr_rows.At(i);
      if(CheckPointer(m_arr_cells)==POINTER_INVALID)
         return(false);
      CEdit *m_cell=m_arr_cells.At(m_columns-1);
      if(CheckPointer(m_cell)==POINTER_INVALID)
         return(false);
      //--- resize "rows" according to hidden vertical scroll bar
      if(!m_cell.Width(m_columns_size[m_columns-1]-CONTROLS_BORDER_WIDTH))
         return(false);
     }
//--- event is handled
   return(true);
  }
//+------------------------------------------------------------------+
//| Handler of the "Scroll up for one row" event                     |
//+------------------------------------------------------------------+
bool CTableListView::OnScrollLineUp(void)
  {
//--- get new offset
   m_offset=m_scroll_v.CurrPos();
//--- redraw
   return(Redraw());
  }
//+------------------------------------------------------------------+
//| Handler of the "Scroll down for one row" event                   |
//+------------------------------------------------------------------+
bool CTableListView::OnScrollLineDown(void)
  {
//--- get new offset
   m_offset=m_scroll_v.CurrPos();
//--- redraw
   return(Redraw());
  }
//+------------------------------------------------------------------+
//| Handler of click on row                                          |
//+------------------------------------------------------------------+
bool CTableListView::OnItemClick(const int index_row,const int index_column)
  {
//--- select "row"
   Select(index_row+m_offset,index_column);
//--- send notification
   EventChartCustom(CONTROLS_SELF_MESSAGE,ON_CLICK,m_id,0.0,m_name);
//--- handled
   return(true);
  }
//+------------------------------------------------------------------+
