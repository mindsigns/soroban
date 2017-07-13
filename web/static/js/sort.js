import tablesort from "tablesort"

export const Sort = {
  makeSortable: () => {
    const table = document.getElementById('sortable')
    tablesort(table)
  }
}
