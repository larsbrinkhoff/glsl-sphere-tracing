typedef struct
{
  float x, y, z;
} vec3;

struct node
{
  union
  {
    float split;
    /* pointer to primitives */
  };
  union
  {
    int flags;
    /* number of primitives */
    int child;
  };
};

#define KD_X 1
#define KD_Y 2
#define KD_Z 4

struct node * kd_search (struct node *tree, vec3 *point, int i)
{
  struct node *node = &tree[i];
  float p;

  if (node->flags & KD_X)
    p = point->x;
  else if (node->flags & KD_Y)
    p = point->y;
  else if (node->flags & KD_Z)
    p = point->z;
  else
    return node;

  return kd_search (tree, point, p < tree->split ? i+1 : node->child);
}

struct node * kd_search_compiled (struct node *tree, vec3 *point)
{
  if (point->x < 12.34f)
    goto child1;
  else
    goto child2;

 child1:
  if (point->z < 1.234f)
    goto child3;
  else
    goto child4;

 child2:
  if (point->y < 0.1234f)
    goto child5;
  else
    goto child6;

 child3:
  return &tree[3];
 child4:
  return &tree[4];
 child5:
  return &tree[5];
 child6:
  return &tree[6];
}

#if 0
(defun kd-search (tree point i)
  (let* ((node (aref tree i))
	 (p (case (split-axis node)
	      (:x	(vec-x point))
	      (:y	(vec-y point))
	      (:z	(vec-z point))
	      (t	(return-from kd-search node)))))
    (kd-search tree point (if (< p (split node)) (1+ i) (child node)))))

(defun kd-search-compiled (tree point)
  (tagbody
   (if (< (vec-x point) 12.34f)
       (go child1)
       (go child2))
   child1
   (if (< (vec-z point) 1.234f)
       (go child3)
       (go child4))
   child2
   (if (< (vec-y point) .1234f)
       (go child5)
       (go child6))
   child3
     (return-from kd-search-compiled (aref tree 3))
   child4
     (return-from kd-search-compiled (aref tree 4))
   child5
     (return-from kd-search-compiled (aref tree 5))
   child6
     (return-from kd-search-compiled (aref tree 6))))
#endif
