using UnityEngine;

namespace CodeBase.Rendering
{
    public class EmissionChanger : MonoBehaviour
    {
        [SerializeField]
        private Color _emissionColor1;
        [SerializeField]
        private Color _emissionColor2;
        [SerializeField]
        private Color _emissionColor3;
        
        private MeshRenderer _meshRenderer;
        private Material _material;
        
        private static readonly int EmissionColor1 = Shader.PropertyToID("_EmissionColor1");
        private static readonly int EmissionColor2 = Shader.PropertyToID("_EmissionColor2");
        private static readonly int EmissionColor3 = Shader.PropertyToID("_EmissionColor3");
        
        private void Awake()
        {
            _meshRenderer = GetComponent<MeshRenderer>();
            var material = _meshRenderer.material;
            
            _material = new Material(material);
            _meshRenderer.material = _material;
        }

        private void Update()
        {
            _material.SetColor(EmissionColor1, _emissionColor1);
            _material.SetColor(EmissionColor2, _emissionColor2);
            _material.SetColor(EmissionColor3, _emissionColor3);
        }
    }
}
