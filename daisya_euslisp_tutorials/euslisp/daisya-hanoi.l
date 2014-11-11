;;;
;;; ��ư��֥�ǥ��Ȥä�Hanoi�����Ȥ�����ץ�
;;;    2009/11/14 written by nakanish
;;;
(load "daisya.l")    ;;��֥�ǥ����������ե������load

;;���ܥåȤ�ɽ������viewer���ʤ����viewer��������롣
(if (not (boundp '*irtviewer*))
    (setq *irtviewer* (make-irtviewer)))

;;��֥�ǥ����
(defun init-daisya nil
  ;;��������֥�ǥ�����, *daisya*�Ȥ����ѿ�����֥�ǥ��instance��bind�����
  (setq *daisya* (instance daisyaclass :init)) 
  ;;�ձ�ư�ؤ��򤭤䤹������������ѹ�
  (send *daisya* :reset-pose)
  ;;���̤�ɽ��
  (objects (list *daisya*)))

;;�ձ�ư�ؤΥƥ��ȡʥ���ץ�ˤ�¹Ԥ���
(defun ik-test (&optional (pos #f(300.204 10.0 180.618)))
  ;;�ձ�ư�ؤ��򤭤䤹������������ѹ�
  (send *daisya* :reset-pose)
  ;;���̤򹹿�
  (send *irtviewer* :draw-objects)
  ;;inverse-kinematics�Ȥ����ձ�ư�ؤ�Ȥ�method��ƤӽФ���
  ;;  Jacobian��Ȥä���«�׻��˴𤯵ձ�ư�ؤ���������Ƥ��롣
  ;;����������
  ;; pos�Ǽ������ɸ���֡�rotation-axis�ǲ�ž������ޤ��IK��Ȥ����ʺ���nil�ʤΤǲ�ž��̵���
  ;; debug-view��t�ˤ���ȡ�IK���Jacobian�μ�«���ͻҤ����褹��
  (send *daisya* :inverse-kinematics (make-cascoords :pos #f(300.204 10.0 180.618)) 
        :rotation-axis nil :debug-view t)
  ;;
  ;;���Ҥ餯
  (send *daisya* :open-hand)
  ;;����򹹿�
  (send *irtviewer* :draw-objects))
;;
;;;
;;; hanoi sample
;;;
;;����d��fromk��to�إ��ܥåȤ�Ȥä�ư��������δؿ�
(defun move-disk (d from to) ;; re-define
  (let (pav)
    (if (eq from 'ground)
        (move-on d (table-top to))
      (progn
        (move-arm d 'pick)
        (move-arm (get (table-top to) :top-coords) 'place)))
    (setf (get from :disks) (cdr (get from :disks)))
    (setf (get to :disks) (cons d (get to :disks)))
    ))
;;to�ޤ��Ӥ�ư�����ơ�pick/place��'pick�ʤ�Ĥ���ư���'place�ʤ����֤���ư���Ԥ�
(defun move-arm (to pick/place)
  (let ()
    (unless
	;;*robot*��ǥ���Ф��ơ�:pick, :place�Ȥ���method������
	;;��ư��֤Υ�ǥ�ե������daisya.l��(:pick, (:place���������Ƥ���Τ�
	;;���Ƥߤ�Ȥ狼�뤬���ձ�ư�ؤ���ɸ�ޤǼ�򿭤Ф�����򳫤����Ĥ���ˤȤ������Ȥ�
	;;���Ƥ���
        (send *robot* (if (eq pick/place 'pick) :pick :place)
              to :rotation-axis nil
              :obstacles
              (remove-if #'(lambda (x) (< (norm (send x :difference-position to :translation-axis :z)) 50)) *tables*)
              :use-wheel t
              :debug-view :no-message
              )
      (break))
    (send *irtviewer* :draw-objects)))

;;��֤�Ȥä�Hanoi�����Ȥ�����ץ�
(defun hanoi-test nil
  ;;robot�����ꡧ�����Ǥ���֥�ǥ��*daisya*)��Ȥ�
  (setq *robot* *daisya*)  
  ;;
  ;;Hanoi����ι⤵�����֡�̾��������
  (setq *table-a* (hanoi-table :name "table-a" :height 125 :pos #f(300 200 0)))
  (setq *table-b* (hanoi-table :name "table-b" :height 150 :pos #f(350 0 0)))
  (setq *table-c* (hanoi-table :name "table-b" :height 100 :pos #f(300 -200 0)))
  (setq *tables* (list *table-a* *table-b* *table-c*))
  ;;
  ;;Hanoi����ν��������֤�����ʣ��Ĥ�disk��table-a������)
  (hanoi-init 3 *table-a*)
  (setq *disk-1* (car *disks*))
  (setq *disk-2* (cadr *disks*))
  (setq *disk-3* (caddr *disks*))
  ;;
  ;;IK��Ȥ��䤹�����֤���ֻ����򥻥å�
  (send *daisya* :reset-pose)
  ;;���(*robot*)��Hanoi����(*tables*)������(*disks*)��ɽ������
  (objects (append *tables* *disks* (list *robot*)))
  ;;
  ;;�����Ȥ� 
  ;;
  ;;�ؿ�hanoi-program��¹Ԥ���ȡ����ޤǤι�ư�ꥹ�Ȥ����������
  ;; �����dolist�ΰ�����Ϳ���뤳�Ȥǡ�����礬�缡action�˳�Ǽ����Ƥ���
  (dolist (action (hanoi-program (length *disks*)))
    ;;��ư��shell��ɽ��
    (print action)
    ;;��ư��ºݤ˥��ܥå���֤�ȤäƼ¹�
    (eval action)
    ;;���٤ߤ���
    (unix:usleep (* 300 1000))
    ))
(warn "
(hanoi-test)
")
;;(load "daisya-hanoi.l")�򤹤�ȡ����δؿ����ƤФ��Τǡ�
;;��ưŪ�ˡ�viewer����ܥå���֥�ǥ�κ�����ɽ�����Ԥ���Ȥ�������
(init-daisya)
;;
;; Hanoi������ۤ��뤿��δؿ�
;;
;;Hanoi����Υơ��֥��ǥ����������
(defun hanoi-table
  (&key (name) (pos (float-vector 0 0 0)) (height 200))
  ;;(setf height (* 1.5 height))
  (let ((b (make-cylinder 30 height))
        (c (make-cube 80 80 4))
        bs)
    (send c :locate (float-vector 0 0 height))
    (send c :set-color :gray90)
    (send b :set-color :gray90)
    (send b :assoc c)
    (setq bs (instance bodyset-link :init (make-cascoords :coords (send c :copy-worldcoords))
                       :bodies (list b c)))
    (setf (get bs :top-face)
          (car (send c :get-face :cube :top)))
    (setf (get bs :top-coords)
          (face-coords (get bs :top-face)))
    (send bs :assoc (get bs :top-coords))
    (send bs :locate pos)
    (send bs :name name)
    bs
    ))

(defun face-center (f)
  (cadr (send f :centroid)))
(defun face-coords
  (f &optional (c (make-cascoords)))
  (setq c (copy-object c))
  (send c :locate (face-center f) :world)
  c)

;;Hanoi����α��ĥ�ǥ����������
(defun hanoi-disk (&optional r h)
  (let* ((c (make-cylinder r h)))
    (setf (get c :top-face)
          (car (send c :get-face :cylinder :top)))
    (setf (get c :top-coords)
          (face-coords (get c :top-face)))
    (send c :assoc (get c :top-coords))
    (setf (get c :grasp-width) (* r 2))
    c
    ))

;;Hanoi����α��ĥ�ǥ��Ŀ�������ˤ���ʣ����������ʤ�����󾮤����������Ѳ�����������)
(defun disks (n &optional disks)
  (dotimes (i n)
    (setq disks (cons (hanoi-disk (+ (* (/ 27 n) i) 12) 20)
                      disks))
    (send (car disks) :set-color (send (elt gl::*face-colors* (* (+ i 4) 32)) :name))
    (send (car disks) :name (format nil "disk~A" i))
    )
  (reverse disks))

;;i���ܤ�disk���֤�
(defun disk (i) (elt *disks* (1- i)))
;;
;; define motions
;;
(defun table-top (table)
  (if (get table :disks)
      (car (get table :disks))
    table))
(defun move-on (o to)
  (send o
        :locate
        (v+ (send (get to :top-coords) :worldpos)
            #f(0 0 0.05))
        :world)
  )
;;;
;;; define planning
;;;
;;a,b�ʳ���tablelist���֤�
(defun other-table
  (a b
   &optional
   (tables '(*table-a* *table-b* *table-c*)))
  (car (remove b (remove a tables))))
;;Hanoi������褹��
(defun hanoi-program
  (&optional
   (n 3)
   (from '*table-a*)
   (to '*table-b*)
   (other (other-table from to)))
  (cond
      
      ((= n 1)
       (list (list 'move-disk (list 'disk n)
                   from to)))
    (t (append
        (hanoi-program (1- n) from other)
        (list (list 'move-disk (list 'disk n) from to))
        (hanoi-program (1- n) other to))))
  )
;;
;;hanoi���������򥻥åȤ���
(defun hanoi-init (n initial-table)
  (setq *disks* (disks n))
  (setq *worlds* (append *disks* *tables*))
  (dotimes (i n)
    (move-disk (disk (- n i))
               'ground initial-table))
  )
