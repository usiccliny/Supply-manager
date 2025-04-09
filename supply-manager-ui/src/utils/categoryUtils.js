export const buildCategoryTree = (categories) => {
  const tree = [];
  const categoryMap = {};

  categories.forEach((category) => {
    if (!category.name || !category.id) {
      console.error('Некорректная категория:', category);
      return;
    }
    category.children = [];
    categoryMap[category.id] = category;
  });

  categories.forEach((category) => {
    if (category.parentId === null) {
      tree.push(category);
    } else {
      const parent = categoryMap[category.parentId];
      if (parent) {
        parent.children.push(category);
      }
    }
  });

  return tree;
};